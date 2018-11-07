/*
 * * * Compile_AHK SETTINGS BEGIN * * *

[AHK2EXE]
Exe_File=%In_Dir%\uupdownloader.exe
Alt_Bin=C:\Program Files\AutoHotkey\Compiler\Unicode 32-bit.bin
No_UPX=1
Run_Before="build\prepare.cmd"
Run_After="build\clean.cmd"
Execution_Level=4
[VERSION]
Set_Version_Info=1
Company_Name=UUP dump authors
File_Description=UUP dump downloader
File_Version=0.4.0.0
Inc_File_Version=0
Legal_Copyright=(c) 2018 UUP dump authors
Product_Name=UUP dump downloader
Product_Version=0.4.0.0
[ICONS]
Icon_1=%In_Dir%\files\icon.ico
Icon_2=0
Icon_3=0
Icon_4=0
Icon_5=0

* * * Compile_AHK SETTINGS END * * *
*/

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetBatchLines -1
#NoTrayIcon
#SingleInstance off

Version = 0.4.0-alpha
AppNameOnly = UUP dump downloader

AppName = %AppNameOnly% v%version%
UserAgent = %AppNameOnly%/%version%

#Include lib\Subprocess.ahk

if A_IsAdmin = 0
{
    MsgBox, 16, %AppName%, This application needs to be run as administrator.
    ExitApp
}

if A_OSVersion in WIN_NT4,WIN_95,WIN_98,WIN_ME,WIN_2000,WIN_XP,WIN_2003,WIN_VISTA
{
    MsgBox, 16, %AppName%, This application requires Windows 7 or later.
    ExitApp
}

Instruction := "Preview version"
Content := "This is a preview version of " AppName ".`n`nThis means that this application may work incorrectly, cause unknown problems or even remove files. YOU HAVE BEEN WARNED.`n`nDo you want to continue?"

Result := TaskDialog(Instruction, Content, AppName, 0x6, 0xFFFF)

if(Result == "No") {
    ExitApp
}

Result =
Instruction =
Content =

SplitPath, A_ScriptFullPath,,,,, ScriptDrive
BaseDir = %ScriptDrive%\$UUPDUMP

Loop {
	Random, instance, 0, 2147483647
	WorkDir = %BaseDir%\%instance%
} until !FileExist(WorkDir)

FileCreateDir, %WorkDir%
FileSetAttrib, +H, %BaseDir%

IfNotExist, %WorkDir%
{
	MsgBox, 16, Error, Failed to create working directory.
	ExitApp
}

Gui Font, s9, Segoe UI
Gui Font
Gui Font, s16, Segoe UI
Gui Add, Text, x16 y13 w480 h32 +0x200 +Center, %AppName%
Gui Font
Gui Font, s9, Segoe UI
Gui Add, DropDownList, x24 y85 w396 +AltSubmit +Disabled gShowBuildToolTip vBuildSelect,
Gui Add, Button, x428 y84 w60 h25 +Disabled gBuildSelectOK vBuildSelectBtn, &OK
Gui Add, Text, x24 y152 w224 h23, Language
Gui Add, DropDownList, x24 y175 w224 +AltSubmit +Disabled vLangSelect gLangSelected
Gui Add, Text, x264 y152 w224 h23, Edition
Gui Add, DropDownList, x264 y175 w224 +AltSubmit +Disabled vEditionSelect gEditionSelected
Gui Add, GroupBox, x16 y60 w480 h60, Build selection
Gui Add, GroupBox, x16 y132 w480 h80, Language and edition
Gui Add, GroupBox, x16 y226 w480 h88, Save options
Gui Add, Edit, x24 y251 w376 h22 vDestinationLocation, %A_ScriptDir%
Gui Add, Button, x408 y250 w80 h24 gFindFolder, &Browse...
Gui Add, Checkbox, x24 y282 w224 h24 vProcessSaveUUP gChangeStateOfSkipConversionButton, Save UUPs to "UUPs" subdirectory
Gui Add, Checkbox, x264 y282 w224 h24 vProcessSkipConversion +Disabled, Skip UUP to ISO conversion
Gui Add, Custom, x16 y324 w480 h58 ClassButton +0x200E gStartProcess vStartProcessBtn +Disabled, &Start process`nDownloads selected build and creates ISO image from it

Gui, +Disabled
Gui Show, w512 h398, %AppName%
Gosub, PrepareEnv
Gui, -Disabled
Gui, Show, NoActivate, %AppName% (API v%APIVersion%)
Return

PrepareEnv:
    SetWorkingDir %WorkDir%

    FileCreateDir, files
    Progress, 0 WM400 C00 ZH16 AM R0-10001, , Preparing working directory..., Please wait..., Segoe UI
    FileInstall, files\7za.exe, %WorkDir%\files\7za.exe
    FileInstall, files\workdir.7z, %WorkDir%\workdir.7z
    FileInstall, files\converter.7z, %WorkDir%\converter.7z
    RunWait, files\7za.exe x workdir.7z, , Hide
    RunWait, files\7za.exe x converter.7z, , Hide
    FileDelete, workdir.7z
    FileDelete, converter.7z

    Command = %ComSpec% /c files\php\php.exe -c files\php\php.ini -r "echo 'PHPTESTSUCCESS';"
    Proc := Subprocess_Run(Command)
    while(Proc.Status == 0)
    {
        Sleep, 10
    }

    PHPTEST := Proc.StdOut.ReadAll()

    if(PHPTEST != "PHPTESTSUCCESS")
    {
        MsgBox, 16, Error,
(
PHP backend test failed. Without this backend working this application cannot continue to operate.

What does this mean?
 - You don't have Visual C++ Redistributable 2015 x86 installed
 - Your antivirus is interfering with the process

If problem persists:
 - Install Visual C++ Redistributable 2015 x86
 - Please disable your antivirus solution temporarily

The application will close.
)

        gosub, KillApplication
    }

    FileDelete, phptest.txt

    Progress, 1001
    Progress, 1000, , Retrieving API...
    Sleep, 1

    URLDownloadToFile, https://gitlab.com/uup-dump/api/-/archive/master/api-master.zip, api.zip
    RunWait, files\7za.exe x api.zip, , Hide
    FileMoveDir, api-master, src\api
    FileDelete, api.zip
    Progress, 6001
    Progress, 6000, , Retrieving list of builds...
    Sleep, 1

    Command = %ComSpec% /c files\php\php.exe -c files\php\php.ini src\apiver.php
    Proc := Subprocess_Run(Command)
    while(Proc.Status == 0)
    {
        Sleep, 10
    }

    APIVersion := Proc.StdOut.ReadAll()

    BuildIDs := PopulateBuildList()
    Progress, 10001
    Progress, 10000

    GuiControl Enable, BuildSelect
    GuiControl Enable, BuildSelectBtn

    Progress, Off
Return

BuildSelectOK:
    Gui Submit, NoHide
    GuiControl, Disable, BuildSelectBtn
    GuiControl, Disable, LangSelect
    GuiControl, Disable, EditionSelect
    GuiControl, Disable, StartProcessBtn

    SelectedBuild := BuildIDs[BuildSelect]
    if(GetFileInfoForUpdate(SelectedBuild) = 0)
    {
        GuiControl, Enable, BuildSelectBtn
        Return
    }

    LangCodes := PopulateLangList(SelectedBuild)
    GuiControl, Enable, BuildSelectBtn
    if LangCodes != 0
        Gosub, LangSelected
Return

LangSelected:
    Gui Submit, NoHide
    GuiControl, Disable, BuildSelectBtn
    GuiControl, Disable, EditionSelect
    GuiControl, Disable, StartProcessBtn
    SelectedLang := LangCodes[LangSelect]

    EditionCodes := PopulateEditionList(SelectedBuild, SelectedLang)
    GuiControl, Enable, BuildSelectBtn
    GuiControl, Enable, LangSelect

    if EditionCodes != 0
        Gosub, EditionSelected
Return

EditionSelected:
    Gui Submit, NoHide
    GuiControl, Disable, BuildSelectBtn
    GuiControl, Disable, StartProcessBtn
    SelectedEdition := EditionCodes[EditionSelect]

    GuiControl, Enable, BuildSelectBtn
    GuiControl, Enable, LangSelect
    GuiControl, Enable, StartProcessBtn
Return

ChangeStateOfSkipConversionButton:
    Gui, Submit, NoHide
    if ProcessSaveUUP = 1
    {
        GuiControl, Enable, ProcessSkipConversion
    } else {
        GuiControl,, ProcessSkipConversion, 0
        GuiControl, Disable, ProcessSkipConversion
        Gui, Submit, NoHide
    }
Return

StartProcess:
    if(A_GuiEvent != "Normal")
        Return

    Gui Submit, NoHide

    DownloadScript = aria2_download.cmd
    if ProcessSkipConversion = 1
        DownloadScript = aria2_download_noconvert.cmd

    IfNotExist, %DestinationLocation%
    {
        MsgBox, 16, Error, Destination location does not exist.
        Return
    }

    Gui, +Disabled
    Progress, 0 WM400 C00 ZH16 AM R0-10001, , Retrieving list of files..., Please wait..., Segoe UI
    RunWait, %ComSpec% /c files\php\php.exe -c files\php\php.ini src\get.php %SelectedBuild% %SelectedLang% %SelectedEdition% 2>>files\uupdump.log 1>files\aria2_script.txt, , Hide

    if ErrorLevel <> 0
    {
        Progress, Off
        MsgBox, 16, Error, Failed to get list of available files. Selected build may be no longer downloadable.
        Gui, -Disabled
        Gui, Show
        Return
    }
    Progress, 10001
    Progress, 10000

    Gui, Hide
    Gui, -Disabled
    Progress, Off

    RunWait, %ComSpec% /c %DownloadScript%

    if ErrorLevel <> 0
    {
        Progress, Off
        Instruction := "Command prompt window has been closed or an error occurred."
        Content := "Do you want to restart the download and conversion process using files that have been downloaded so far?`n`nIf you choose ""No"" all downloaded files will be removed."

        Result := TaskDialog(Instruction, Content, AppName, 0x6, 0xFFFD)

        If (Result == "Yes") {
            Gosub, StartProcess
        }

        Gosub, KillApplication
    }

    Instruction := "Process complete"
    Content := "Click OK to start process of moving final files to destination directory. This process may take a while depending on a speed of your hard drive."

    TaskDialog(Instruction, Content, AppName, 0x1, 0xFFFD)

    Loop, Files, %WorkDir%\*.ISO, F
        MoveFileToLocation(DestinationLocation, A_LoopFileFullPath)

    if ProcessSaveUUP = 1
    {
        FileDelete, %WorkDir%\UUPs\.README

        IfNotExist, %DestinationLocation%\UUPs
            FileCreateDir, %DestinationLocation%\UUPs

        Loop, Files, %WorkDir%\UUPs\*.*, F
            MoveFileToLocation(DestinationLocation "\UUPs", A_LoopFileFullPath)
    }

    Instruction := "Information"
    Content := "Task has been completed."

    TaskDialog(Instruction, Content, AppName, 0x1, 0xFFFD)
    Gosub, KillApplication
Return

HideToolTip:
    ToolTip
Return

GuiClose:
KillApplication:
    Progress, off
    Gui Destroy
    FileRemoveDir %WorkDir%, 1

    Loop, Files, %BaseDir%\*, D
    {
        DirectoryHasItems = 1
        Break
    }
    if(!DirectoryHasItems) {
        FileRemoveDir %BaseDir%, 1
    }
    ExitApp
Return

#IfWinActive, ahk_class AutoHotkeyGUI
!D::
    if(!FileExist(WorkDir)) {
        MsgBox, 16, Error, Workdir has not been created yet
        Return
    }
    Run, %A_WinDir%\Explorer.exe %WorkDir%
Return
#IfWinActive

ShowBuildToolTip(CtrlHwnd) {
    ControlGetText, CtrlText, , ahk_id %CtrlHwnd%
    ControlGetPos, X, Y, , , , ahk_id %CtrlHwnd%
    Y += 24
    IfWinActive, ahk_class AutoHotkeyGUI
    {
        ToolTip %CtrlText%, %X%, %Y%
        SetTimer, HideToolTip, -2000
    }
}

FindFolder() {
    Global ScriptDrive
    FileSelectFolder, DestinationLocation, , 3, Browse for destination location of ISO image
    if DestinationLocation !=
    {
        GuiControl, , DestinationLocation, %DestinationLocation%
    }

    SplitPath, DestinationLocation,,,,, SelectedDrive
    if(SelectedDrive <> ScriptDrive)
        MsgBox, 48, Warning, Selected path is on a different disk than executable of this application. Due to this the final copy process may take a long time. For quick copy process, please run this application from a disk on which you wish to save the final files.
}

PopulateBuildList() {
    Response := UrlGet("https://uupdump.ml/listid.php", "GET")

    BuildList =
    BuildIDs := []

    Loop, Parse, Response, `n
    {
        RegExMatch(A_LoopField, "SO)(.*)\|(.*)\|(.*)\|(.*)", Match)
        Build := Match.1
        Arch := Match.2
        ID := Match.3
        Name := Match.4

        if ID !=
        {
            BuildIDs[A_Index] := ID
            BuildList .= Name " " Arch "|"
            if(A_Index = 1)
            {
                BuildList .= "|"
            }
        }
    }

    if BuildList =
    {
        MsgBox, 16, Error, Cannot retrieve list of available builds.
        Gosub, KillApplication
    }

    GuiControl, , BuildSelect, %BuildList%
    Return BuildIDs
}

PopulateLangList(SelectedBuild) {
    Command = %ComSpec% /c files\php\php.exe -c files\php\php.ini src\listlangs.php %SelectedBuild%
    Proc := Subprocess_Run(Command)

    while(Proc.Status == 0)
    {
        Sleep, 10
    }

    Output := Proc.StdOut.ReadAll()
    StdErr := Proc.StdErr.ReadAll()
    FileAppend, %StdErr%, files\uupdump.log

    GuiControl, , LangSelect, |
    LangList =
    LangCodes := []

    Loop, Parse, Output, `n
    {
        RegExMatch(A_LoopField, "SO)(.*)\|(.*)", Match)
        Code := Match.1
        Lang := Match.2

        if Code !=
        {
            LangCodes[A_Index] := Code
            LangList .= Lang "|"
            if(Code = "en-us")
            {
                LangList .= "|"
            }
        }
    }

    if LangList =
    {
        MsgBox, 16, Error, There are no languages available for this selection.
        Return 0
    }

    GuiControl, , LangSelect, %LangList%
    GuiControl, Enable, LangSelect

    Return LangCodes
}

PopulateEditionList(SelectedBuild, Lang) {
    Global LangCodes, LangSelect

    Command = %ComSpec% /c files\php\php.exe -c files\php\php.ini src\listeditions.php %Lang% %SelectedBuild%
    Proc := Subprocess_Run(Command)

    while(Proc.Status == 0)
    {
        Sleep, 10
    }

    Output := Proc.StdOut.ReadAll()
    StdErr := Proc.StdErr.ReadAll()
    FileAppend, %StdErr%, files\uupdump.log

    Gui, Submit, NoHide
    SelectedLang := LangCodes[LangSelect]

    If(Lang != SelectedLang)
        Return PopulateEditionList(SelectedBuild, SelectedLang)

    GuiControl, , EditionSelect, |
    EditionList =
    EditionCodes := []
    EditionCodes[1] := 0

    Loop, Parse, Output, `n
    {
        RegExMatch(A_LoopField, "SO)(.*)\|(.*)", Match)
        Code := Match.1
        Edition := Match.2

        if Code !=
        {
            EditionCodes[A_Index+1] := Code
            EditionList .= Edition "|"
        }
    }

    if EditionList =
    {
        MsgBox, 16, Error, There are no editions available for this selection.
        Return 0
    }

    EditionList = All editions||%EditionList%
    GuiControl, , EditionSelect, %EditionList%
    GuiControl, Enable, EditionSelect

    Return EditionCodes
}

GetFileInfoForUpdate(Update) {
    Progress, 0 WM400 C00 ZH16 AM R0-10001, , Retrieving fileinfo..., Please wait..., Segoe UI
    Sleep, 16
    Gui, +Disabled

    IfNotExist fileinfo
    {
        FileCreateDir fileinfo
    }

    IfNotExist fileinfo\%Update%.json
    {
        Response := UrlGet("https://gitlab.com/uup-dump/fileinfo/raw/master/" Update ".json", "HEAD")

        if(Response != 200)
        {
            MsgBox, 16, Error, Fileinfo database does not exist for this selection.
            Gui, -Disabled
            Progress, Off
            Return 0
        }
        Progress, 1001
        Progress, 1000
        URLDownloadToFile, https://gitlab.com/uup-dump/fileinfo/raw/master/%Update%.json, fileinfo\%Update%.json
    }

    Progress, 5001
    Progress, 5000, , Retrieving packs...

    IfNotExist packs
    {
        FileCreateDir packs
    }

    IfNotExist packs\%Update%.json.gz
    {
        Response := UrlGet("https://gitlab.com/uup-dump/packs/raw/master/" Update ".json.gz", "HEAD")

        if(Response = 200)
        {
            Progress, 6001
            Progress, 6000
            URLDownloadToFile, https://gitlab.com/uup-dump/packs/raw/master/%Update%.json.gz, packs\%Update%.json.gz
        }
    }

    Progress, 10001
    Progress, 10000

    Gui, -Disabled
    Progress, off
}

MoveFileToLocation(Dest, File) {
    Global AppName
    SplitPath, File, FileName

    IfNotExist, %Dest%\%FileName%
    {
        FileMove, %File%, %Dest%\%FileName%
    } else {
        MsgBox, 48, %AppName%, %Dest%\%FileName% already exists.`n`nYou will be asked for a new name after clicking OK.
    Loop
    {
        FileSelectFile, NewLocation, S16, %Dest%\%FileName%, Select a new name for %FileName%, (*.iso)
    } until NewLocation <> ""
        FileMove, %File%, %NewLocation%, 1
    }
}

TaskDialog(Instruction, Content := "", Title := "", Buttons := 1, IconID := 0, IconRes := "", Owner := 0x10010) {
    Local hModule, LoadLib, Ret

    If (IconRes != "") {
        hModule := DllCall("GetModuleHandle", "Str", IconRes, "Ptr")
        LoadLib := !hModule
            && hModule := DllCall("LoadLibraryEx", "Str", IconRes, "UInt", 0, "UInt", 0x2, "Ptr")
    } Else {
        hModule := 0
        LoadLib := False
    }

    DllCall("TaskDialog"
        , "Ptr" , Owner        ; hWndParent
        , "Ptr" , hModule      ; hInstance
        , "Ptr" , &Title       ; pszWindowTitle
        , "Ptr" , &Instruction ; pszMainInstruction
        , "Ptr" , &Content     ; pszContent
        , "Int" , Buttons      ; dwCommonButtons
        , "Ptr" , IconID       ; pszIcon
        , "Int*", Ret := 0)    ; *pnButton

    If (LoadLib) {
        DllCall("FreeLibrary", "Ptr", hModule)
    }

    Return {1: "OK", 2: "Cancel", 4: "Retry", 6: "Yes", 7: "No", 8: "Close"}[Ret]
}

UrlGet(URL, Method) {
    Global UserAgent
    WebRequest := ComObjCreate("MSXML2.XMLHTTP.3.0")
    WebRequest.Open(Method, URL, false)
    WebRequest.setRequestHeader("User-Agent", UserAgent)
    WebRequest.Send()
    if(Method = "HEAD")
        Return WebRequest.Status

    Return WebRequest.ResponseText
}
