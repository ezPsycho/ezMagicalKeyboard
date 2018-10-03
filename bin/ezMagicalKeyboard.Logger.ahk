#NoTrayIcon
#SingleInstance force

SetWorkingDir %A_ScriptDir%

#Include %A_ScriptDir%\talk.ahk

GUIWindow := new talk("ezMagicalKeyboard.Gui")

Loop
{
  Input, Key, L1 V I
  If (GUIWindow.getvar("sLoggerEnabled"))
  {
    If RegExMatch(Key, "^[a-z0-9]$")
    {
      GUIWindow.setvar("loggedKey", Key, 1)
      GUIWindow.runlabel("SendLoggedKey", 1)
    }
  }
}
Return