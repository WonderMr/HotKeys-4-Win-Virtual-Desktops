#SingleInstance force
#InstallKeybdHook force

; Globals
DesktopCount                =   2                                                                                                       ; Windows starts with 2 desktops at boot
CurrentDesktop              =   1                                                                                                       ; Desktop count is 1-indexed (Microsoft numbers them this way)
;
; This function examines the registry to build an accurate list of the current virtual desktops and which one we're currently on.
; Current desktop UUID appears to be in HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SessionInfo\1\VirtualDesktops
; List of desktops appears to be in HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops
;
mapDesktopsFromRegistry() {
    global CurrentDesktop, DesktopCount                                                             ; Get the current desktop UUID. Length should be 32 always, but there's no guarantee this couldn't change in a later Windows release so we check.
    IdLength                    :=  32
    SessionId                   :=  getSessionId()
    if (SessionId) {
        RegRead, CurrentDesktopId, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SessionInfo\%SessionId%\VirtualDesktops, CurrentVirtualDesktop
        if (CurrentDesktopId) {
            IdLength            :=  StrLen(CurrentDesktopId)
        }
    } 
    ; Get a list of the UUIDs for all virtual desktops on the system
    RegRead, DesktopList, HKEY_CURRENT_USER, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops, VirtualDesktopIDs     
    if (DesktopList) {
        DesktopListLength       :=  StrLen(DesktopList)                                                                                 ; Figure out how many virtual desktops there are    
        DesktopCount            :=  DesktopListLength / IdLength
    }
    else {
        DesktopCount            :=  1
    }
    ; Parse the REG_DATA string that stores the array of UUID's for virtual desktops in the registry.
    i                           :=  0
    while (CurrentDesktopId and i < DesktopCount) {
        StartPos                :=  (i * IdLength) + 1
        DesktopIter             :=  SubStr(DesktopList, StartPos, IdLength)
        ;OutputDebug, The iterator is pointing at %DesktopIter% and count is %i%.
        ; Break out if we find a match in the list. If we didn't find anything, keep the
        ; old guess and pray we're still correct :-D.
        if (DesktopIter         =   CurrentDesktopId) {
            CurrentDesktop      :=  i + 1
            ;OutputDebug, Current desktop number is %CurrentDesktop% with an ID of %DesktopIter%.
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
        ;OutputDebug, Error getting current process id: %ErrorLevel%
        return
    }
    ;OutputDebug, Current Process Id: %ProcessId%
    DllCall("ProcessIdToSessionId", "UInt", ProcessId, "UInt*", SessionId)
    if ErrorLevel {
        ;OutputDebug, Error getting session id: %ErrorLevel%
        return
    }
    ;OutputDebug, Current Session Id: %SessionId%
    return SessionId
}
;
; This function switches to the desktop number provided.
;
switchDesktopByNumber(targetDesktop,scro)
{
    if(scro){
        Send, {ScrollLock 2}
    }else{
        Send, {CapsLock 2}
    }
    #UseHook
    global CurrentDesktop, DesktopCount
    GetKeyState,Scroll,ScrollLock
    GetKeyState,Caps,CapsLock
    OutputDebug, Start scroll = %Scroll% caps = %Caps%
    mapDesktopsFromRegistry()    
    if not(targetDesktop > DesktopCount || targetDesktop < 1) {                                            ; Don't attempt to switch to an invalid desktop                           
        Gui, +AlwaysOnTop +Disabled -SysMenu +Owner                                                         ; Go right until we reach the desktop we want; +Owner avoids a taskbar button.
        Gui, Show, w1 h1
        SendInput, {LCtrl Down}
        SendInput, {LWin Down}
        while(CurrentDesktop < targetDesktop) {       
            Send {Right}        
            CurrentDesktop++
            ;OutputDebug, [right] target: %targetDesktop% current: %CurrentDesktop%
        }    
        while(CurrentDesktop > targetDesktop) {                                                                                                ; Go left until we reach the desktop we want
            Gui, Show, w1 h1        
            Send {Left}
            CurrentDesktop--
            ;OutputDebug, [left] target: %targetDesktop% current: %CurrentDesktop%
        }
    }    
    if(scro){
        SetScrollLockState, Off
        ;SendInput, {ScrollLock UP}
        OutputDebug, Scroll release to up
    }else{
        SetCapsLockState, Off
        ;SendInput, {CapsLock UP}
        OutputDebug, Caps release to up
    }
    SendInput, {LCtrl Up}
    SendInput, {LWin Up}
    GetKeyState,Scroll,ScrollLock
    GetKeyState,Caps,CapsLock
    OutputDebug, End scroll = %Scroll% caps = %Caps%
    Gui, Hide    
    ;SendInput, {LWin Up}
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
    CurrentDesktop                =    %DesktopCount%
    ;OutputDebug, [create] desktops: %DesktopCount% current: %CurrentDesktop%
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
    ;OutputDebug, [delete] desktops: %DesktopCount% current: %CurrentDesktop%
}
; Main
SetKeyDelay, 75
mapDesktopsFromRegistry()
GetKeyState,Scroll,ScrollLock
GetKeyState,Caps,CapsLock
OutputDebug, Loading scroll = %Scroll% caps = %Caps%
;OutputDebug, [loading] desktops: %DesktopCount% current: %CurrentDesktop%
; This section binds the key combo to the switch/create/delete actions
ScrollLock & 1::switchDesktopByNumber(1,true)
ScrollLock & 2::switchDesktopByNumber(2,true)
ScrollLock & 3::switchDesktopByNumber(3,true)
ScrollLock & 4::switchDesktopByNumber(4,true)
ScrollLock & 5::switchDesktopByNumber(5,true)
ScrollLock & 6::switchDesktopByNumber(6,true)
ScrollLock & 7::switchDesktopByNumber(7,true)
ScrollLock & 8::switchDesktopByNumber(8,true)
ScrollLock & 9::switchDesktopByNumber(9,true)
ScrollLock & PgUp::switchDesktopByNumber(CurrentDesktop + 1,true)
ScrollLock & Ins::switchDesktopByNumber(CurrentDesktop - 1,true)
;CapsLock & c::createVirtualDesktop()
;CapsLock & d::deleteVirtualDesktop()
CapsLock & 1::switchDesktopByNumber(1,false)
CapsLock & 2::switchDesktopByNumber(2,false)
CapsLock & 3::switchDesktopByNumber(3,false)
CapsLock & 4::switchDesktopByNumber(4,false)
CapsLock & 5::switchDesktopByNumber(5,false)
CapsLock & 6::switchDesktopByNumber(6,false)
CapsLock & 7::switchDesktopByNumber(7,false)
CapsLock & 8::switchDesktopByNumber(8,false)
CapsLock & 9::switchDesktopByNumber(9,false)
CapsLock & Right::switchDesktopByNumber(CurrentDesktop + 1,false)
CapsLock & Left::switchDesktopByNumber(CurrentDesktop - 1,false)
CapsLock & s::switchDesktopByNumber(CurrentDesktop + 1,false)
CapsLock & a::switchDesktopByNumber(CurrentDesktop - 1,false)
;^+c::createVirtualDesktop()
;^+d::deleteVirtualDesktop()