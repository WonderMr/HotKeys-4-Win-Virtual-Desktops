I'm using windows virtual desktops (VD).
It's very useful tool for me, but, i got some kind of issues.
I like to use fullscreen rdp session on different VD's, but fullscreen RDP session grabs for itself hotkeys to switch between different VD's.
I did not find any solution and write my own one.
You need autohotkey (https://www.autohotkey.com/) installed to use this scrips.
Just run controller.ahk and it will be possible to use new hostkeys, even in fullscreen RDP session:
ScrollLock + Insert - Previous VD
ScrollLock + PageUP - Next VD
ScrollLock + NUM - VD № num
