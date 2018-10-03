SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

run, %A_ScriptDir%/bin/ezMagicalKeyboard.GUI.ahk
run, %A_ScriptDir%/bin/ezMagicalKeyboard.Logger.ahk