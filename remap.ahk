#SingleInstance force
; Globals
DesktopCount                =   2                                                                                                       ; Windows starts with 2 desktops at boot
CurrentDesktop              =   1                                                                                                       ; Desktop count is 1-indexed (Microsoft numbers them this way)
SetScrollLockState, Off
;
; This function examines the registry to build an accurate list of the current virtual desktops and which one we're currently on.
; Current desktop UUID appears to be in HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SessionInfo\1\VirtualDesktops
; List of desktops appears to be in HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops
;
mapDesktopsFromRegistry() {
    global CurrentDesktop, DesktopCount                                                                                                 ; Get the current desktop UUID. Length should be 32 always, but there's no guarantee this couldn't change in a later Windows release so we check.
    IdLength                :=  32
    SessionId               :=  getSessionId()
    if (SessionId) {
        RegRead, CurrentDesktopId, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SessionInfo\%SessionId%\VirtualDesktops, CurrentVirtualDesktop
        if (CurrentDesktopId) {
            IdLength        :=  StrLen(CurrentDesktopId)
        }
    } 
     RegRead, DesktopList, HKEY_CURRENT_USER, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops, VirtualDesktopIDs     ; Get a list of the UUIDs for all virtual desktops on the system
     if (DesktopList) {
        DesktopListLength       :=  StrLen(DesktopList)                                                                                 ; Figure out how many virtual desktops there are    
        DesktopCount            :=  DesktopListLength / IdLength
     }
     else {
        DesktopCount            :=  1
     }
     ; Parse the REG_DATA string that stores the array of UUID's for virtual desktops in the registry.
     i                          :=  0
     while (CurrentDesktopId and i < DesktopCount) {
        StartPos                :=  (i * IdLength) + 1
        DesktopIter             :=  SubStr(DesktopList, StartPos, IdLength)
        OutputDebug, The iterator is pointing at %DesktopIter% and count is %i%.
        ; Break out if we find a match in the list. If we didn't find anything, keep the
        ; old guess and pray we're still correct :-D.
        if (DesktopIter         =   CurrentDesktopId) {
            CurrentDesktop      :=  i + 1
            OutputDebug, Current desktop number is %CurrentDesktop% with an ID of %DesktopIter%.
            break
        }
        i++
    }
}
;
; This functions finds out ID of current session.
;
getSessionId()
{
    ProcessId                   :=  DllCall("GetCurrentProcessId", "UInt")
    if ErrorLevel {
        OutputDebug, Error getting current process id: %ErrorLevel%
        return
    }
    OutputDebug, Current Process Id: %ProcessId%
    DllCall("ProcessIdToSessionId", "UInt", ProcessId, "UInt*", SessionId)
    if ErrorLevel {
        OutputDebug, Error getting session id: %ErrorLevel%
        return
    }
    OutputDebug, Current Session Id: %SessionId%
    return SessionId
}
;
; This function switches to the desktop number provided.
;
switchDesktopByNumber(targetDesktop)
{
    Send, {ScrollLock}
    Send, {ScrollLock}
    SetScrollLockState, Off
    ;MsgBox, %state%    
    global CurrentDesktop, DesktopCount
    ; Re-generate the list of desktops and where we fit in that. We do this because
    ; the user may have switched desktops via some other means than the script.
    mapDesktopsFromRegistry()
    ; Don't attempt to switch to an invalid desktop
    if (targetDesktop > DesktopCount || targetDesktop < 1) {
        OutputDebug, [invalid] target: %targetDesktop% current: %CurrentDesktop%        
        return
    }
    ; Go right until we reach the desktop we want
    Gui, +AlwaysOnTop +Disabled -SysMenu +Owner  ; +Owner avoids a taskbar button.
    Gui, Show, w1 h1
    SendInput, {LCtrl Down}
    SendInput, {LWin Down}
    while(CurrentDesktop < targetDesktop) {       
        Send {Right}        
        CurrentDesktop++
        OutputDebug, [right] target: %targetDesktop% current: %CurrentDesktop%
    }
    ; Go left until we reach the desktop we want
    while(CurrentDesktop > targetDesktop) {
        Gui, Show, w1 h1        
        Send {Left}
        Gui, Hide
        CurrentDesktop--
        OutputDebug, [left] target: %targetDesktop% current: %CurrentDesktop%
    }
    SendInput, {LWin Up}
    SendInput, {LCtrl Up}
    Gui, Hide
    ;Msgbox, %CurrentDesktop%
}
;
; This function creates a new virtual desktop and switches to it
;
createVirtualDesktop()
{
    global CurrentDesktop, DesktopCount
    Gui, Show, w1 h1    
    Send, #^d
    Gui, Hide
    DesktopCount++
    CurrentDesktop = %DesktopCount%
    OutputDebug, [create] desktops: %DesktopCount% current: %CurrentDesktop%
}
;
; This function deletes the current virtual desktop
;
deleteVirtualDesktop()
{
    global CurrentDesktop, DesktopCount
    Gui, Show, w1 h1    
    Send, #^{F4}
    Gui, Hide
    DesktopCount--
    CurrentDesktop--
    OutputDebug, [delete] desktops: %DesktopCount% current: %CurrentDesktop%
}
; Main
SetKeyDelay, 75
mapDesktopsFromRegistry()
OutputDebug, [loading] desktops: %DesktopCount% current: %CurrentDesktop%
; User config!
; This section binds the key combo to the switch/create/delete actions
;RWin & 1::switchDesktopByNumber(1)
;RWin & 2::switchDesktopByNumber(2)
;RWin & 3::switchDesktopByNumber(3)
;RWin & 4::switchDesktopByNumber(4)
;RWin & 5::switchDesktopByNumber(5)
;RWin & 6::switchDesktopByNumber(6)
;RWin & 7::switchDesktopByNumber(7)
;RWin & 8::switchDesktopByNumber(8)
;RWin & 9::switchDesktopByNumber(9)
ScrollLock & 1::switchDesktopByNumber(1)
ScrollLock & 2::switchDesktopByNumber(2)
ScrollLock & 3::switchDesktopByNumber(3)
ScrollLock & 4::switchDesktopByNumber(4)
ScrollLock & 5::switchDesktopByNumber(5)
ScrollLock & 6::switchDesktopByNumber(6)
ScrollLock & 7::switchDesktopByNumber(7)
ScrollLock & 8::switchDesktopByNumber(8)
ScrollLock & 9::switchDesktopByNumber(9)
;CapsLock & n::switchDesktopByNumber(CurrentDesktop + 1)
;CapsLock & p::switchDesktopByNumber(CurrentDesktop - 1)
ScrollLock & PgUp::switchDesktopByNumber(CurrentDesktop + 1)
ScrollLock & Ins::switchDesktopByNumber(CurrentDesktop - 1)
;CapsLock & c::createVirtualDesktop()
;CapsLock & d::deleteVirtualDesktop()
; Alternate keys for this config. Adding these because DragonFly (python) doesn't send CapsLock correctly.
;^+1::switchDesktopByNumber(1)
;^+2::switchDesktopByNumber(2)
;^+3::switchDesktopByNumber(3)
;^+4::switchDesktopByNumber(4)
;^+5::switchDesktopByNumber(5)
;^+6::switchDesktopByNumber(6)
;^+7::switchDesktopByNumber(7)
;^+8::switchDesktopByNumber(8)
;^+9::switchDesktopByNumber(9)
;^+n::switchDesktopByNumber(CurrentDesktop + 1)
;^+p::switchDesktopByNumber(CurrentDesktop - 1)
;^+s::switchDesktopByNumber(CurrentDesktop + 1)
;^+a::switchDesktopByNumber(CurrentDesktop - 1)
;^+c::createVirtualDesktop()
;^+d::deleteVirtualDesktop()