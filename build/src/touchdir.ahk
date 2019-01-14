WorkDir := A_WorkingDir
#Include %A_ScriptDir%\..\..\include\header.ahk
SetWorkingDir, %WorkDir%

Dir = %1%
If(!InStr(FileExist(Dir), "D"))
{
    ExitApp, 1
}

TimeStamp := A_YYYY . A_MM . A_DD . A_Hour . A_Min . A_Sec

FileSetTime, %TimeStamp%, %Dir%\*, M, 1, 1
FileSetTime, %TimeStamp%, %Dir%\*, C, 1, 1
FileSetTime, %TimeStamp%, %Dir%\*, A, 1, 1
