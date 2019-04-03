#SingleInstance force
remap_name      =   "remap.ahk"
Run "autohotkey" %remap_name%

#Persistent
SetTimer, ReloadOnRDPMaximized, 100
return

ReloadOnRDPMaximized:
Sleep, 50
If WinActive("ahk_class TscShellContainerClass")
{
    WinGet, maxOrMin, MinMax, ahk_class TscShellContainerClass

    if (maxOrMin = 0) {
        WinGetPos, PosX, PosY, WinWidth, WinHeight, ahk_class TscShellContainerClass

        if (PosY = 0) {
            ; it is fully maximized therefore reload "remap.ahk"
            Run "autohotkey" %remap_name%
            OutputDebug, "Reloaded"
            WinWaitNotActive, ahk_class TscShellContainerClass

        }
    }
}
return