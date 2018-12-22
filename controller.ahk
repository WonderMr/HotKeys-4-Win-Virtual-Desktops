#SingleInstance force
Run "autohotkey" "remap.ahk"

#Persistent
SetTimer, ReloadOnRDPMaximized, 500
return

ReloadOnRDPMaximized:
Sleep, 1000
If WinActive("ahk_class TscShellContainerClass")
{
    WinGet, maxOrMin, MinMax, ahk_class TscShellContainerClass

    if (maxOrMin = 0) {
        WinGetPos, PosX, PosY, WinWidth, WinHeight, ahk_class TscShellContainerClass

        if (PosY = 0) {
            ; it is fully maximized therefore reload "remap.ahk"
            Run "autohotkey" "remap.ahk"
            ; Msgbox "Reloaded"
            ; wait until window gets deactivated so you don't reload it again.
            WinWaitNotActive, ahk_class TscShellContainerClass

        }
    }
}
return