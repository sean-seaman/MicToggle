; Toggle mic on/off
#SingleInstance force

; read ini file
IniRead, DeviceName, MicToggleSettings.ini, Settings, DeviceName, MASTER
IniRead, DeviceNumber, MicToggleSettings.ini, Settings, DeviceNumber, 1

SysGet, Bounds, MonitorWorkArea
xpos := BoundsRight-70
ypos := BoundsBottom-95

Gui, Add, Picture, X0 Y0, mic.png
; last two options remove title bar and make window unable to be alt+tabbed into, respectively
Gui +LastFound -Caption +E0x80	+AlwaysOnTop		

WinGet ID, ID
WinSet Transparent, 75

; the following magic makes a hole to click through the window to whatever's below
; created by VxE here: https://autohotkey.com/board/topic/34900-mouse-click-through-window/
; I don't know you, but thank you for being a wizard
OnMessage(0x200, "WM_MouseMove")
SetTimer, PollMouse, 25 ; this doesn't need a short period since the
; WM_MouseMove message takes care of most of the position-checking
PollMouse:
MouseGetPos, x, y, w
If (w != GuiHWND) || (x=ox && y=oy)
	return
ox := x
oy := y
WM_MouseMove(0, y << 16 | x, 0, w)
return

WM_MouseMove(wparam, lparam, msg, hwnd)
{
	SetWinDelay, -1
	SetBatchLines, -1
	x := lparam & 65535
	y := lparam >> 16
	WinSet, Region, % RegionNotBox(x-1, y-1, x+2, y+2), ahk_id %hwnd%
}

RegionNotBox( L="", T="", R="", B="" )
{
	Static m := "-" , _ := " "
	If R =
		R := (L = "") ? A_ScreenWidth : L+1
	If B =
		B := (T = "") ? A_ScreenHeight : T+1
	If L =
		L = 0
	If T =
		T = 0
	If (L=0) && (T=0) && (R=A_ScreenWidth) && (B=A_ScreenHeight)
		return "0-0 0-0 0-0 0-0"
	return 0 m 0 _ A_ScreenWidth m 0 _ A_ScreenWidth
	. m A_ScreenHeight _ 0 m A_ScreenHeight _ 0 m 0 _
	. l m t _ l m b _ r m b _ r m t _ l m t _ 0 m 0
}

!m::
	; use the soundcard analysis script (https://www.autohotkey.com/docs/commands/SoundSet.htm) to find device number
	SoundSet, +1, %DeviceName%, mute, %DeviceNumber%
	SoundGet, Muted, , mute, %DeviceNumber%
	
	;Mute is "on"/mic is off
	if (Muted == "On")	{
		SoundPlay, micDowntone.wav
		Gui Show, W50 H75 X%xpos% Y%ypos%
	} else {
		SoundPlay, micUptone.wav
		WinHide ahk_id %ID%  ; Hide transparent window
	}

	; reports error message
	if ErrorLevel
		MsgBox, %ErrorLevel%
return