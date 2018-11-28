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
File_Version=1.1.0.1
Inc_File_Version=0
Legal_Copyright=(c) 2018 UUP dump authors
Product_Name=UUP dump downloader
Product_Version=1.1.0.1
[ICONS]
Icon_1=%In_Dir%\files\icon.ico
Icon_2=0
Icon_3=0
Icon_4=0
Icon_5=0

* * * Compile_AHK SETTINGS END * * *
*/

#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

SetBatchLines -1
#NoTrayIcon
#SingleInstance off

Version = 1.1.0-alpha.1
AppNameOnly = UUP dump downloader

AppName = %AppNameOnly% v%version%
UserAgent = %AppNameOnly%/%version%

If !A_IsCompiled
{
    Menu, Tray, Icon, %A_ScriptDir%\files\icon.ico
}

Gui, +OwnDialogs

if A_IsAdmin = 0
{
    MsgBox, 16, %AppName%, This application requires to be run as an administrator.
    ExitApp
}

if A_OSVersion in WIN_NT4,WIN_95,WIN_98,WIN_ME,WIN_2000,WIN_XP,WIN_2003,WIN_VISTA
{
    MsgBox, 16, %AppName%, This application requires Windows 7 or later.
    ExitApp
}

if A_OSVersion in WIN_7,WIN_8,WIN_8.1
{
RegRead, KitsRootWow, HKLM\Software\Wow6432Node\Microsoft\Windows Kits\Installed Roots, KitsRoot10
RegRead, KitsRoot, HKLM\Software\Microsoft\Windows Kits\Installed Roots, KitsRoot10

if (KitsRoot == "" && KitsRootWow == "")
    MsgBox, 68, %AppName%,
(
We've detected that you are using older version of Windows without having Windows 10 ADK installed. Due to this the resulting ISO image may be created incorrectly.

To ensure that the process is successful, please install Windows 10 ADK or use this application on Windows 10.

Do you want to continue?
)
IfMsgBox, No
    ExitApp
}

CurrentPid := DllCall("GetCurrentProcessId")
Random, PhpPort, 49152, 65535
PhpRunCmd = files\php\php.exe -c files\php\php.ini -S 127.0.0.1:%PhpPort% -t src

SplitPath, A_ScriptFullPath,, ScriptDir,, ScriptNameNoExt

IniConfig := ScriptDir "\" ScriptNameNoExt ".ini"
DefaultDir := A_ScriptDir
SpeedLimit = 0

If(FileExist(IniConfig))
{
    IniRead, NewSpeedLimit, %IniConfig%, Config, SpeedLimit
    IniRead, NewDefaultDir, %IniConfig%, Config, DefaultDir

    If(NewSpeedLimit != "ERROR")
        SpeedLimit := NewSpeedLimit

    If(NewDefaultDir != "ERROR")
        DefaultDir := NewDefaultDir
}

StringReplace, Arg1, 1, "
If Arg1 !=
    DefaultDir := Arg1

If(!FileExist(DefaultDir))
{
    DefaultDir := A_ScriptDir
}

SplitPath, DefaultDir,,,,, DefaultDrive
WorkDir := CreateWorkDir(DefaultDrive)

;Header
Gui Add, Text, x0 y0 w512 h54 +0x6
Gui Font, s9 w800, Segoe UI
Gui Add, Text, x16 y8 w480 h23 BackgroundTrans, %AppName%
Gui Font, w400
Gui Add, Text, x16 y31 w480 h23 BackgroundTrans vAppInfo, Preparing application to work...
Gui Font
Gui Font, s9, Segoe UI

;Build search controls
Gui Add, Edit, x24 y85 w376 vBuildSearchQuery
Gui Add, Button, x408 y84 w80 h25 gSearchBuilds vGuiSearchButton +Default, &Search
Gui Add, GroupBox, x16 y60 w480 h256 vGuiSearchGroupBox, Search builds
Gui Add, ListBox, x24 y120 w464 h186 +0x100 +AltSubmit +Disabled vBuildSelect
Gui Add, Custom, x16 y324 w480 h58 gBuildSelectOK vBuildSelectBtn ClassButton +0x200E +Disabled, &Choose selected build`nShows language, edition, and destination location selection page

;Language, edition, destination location controls
Gui Add, Edit, x24 y85 w376 +ReadOnly vSelectedBuildText
Gui Add, Button, x408 y84 w80 h25 gChangeToBuildSearchControls vChangeBuildButton, &Change
Gui Add, Text, x24 y152 w224 h23 vGuiLanguageLabel, Language
Gui Add, DropDownList, x24 y175 w224 +AltSubmit +Disabled vLangSelect gLangSelected
Gui Add, Text, x264 y152 w224 h23 vGuiEditionLabel, Edition
Gui Add, DropDownList, x264 y175 w224 +AltSubmit +Disabled vEditionSelect gEditionSelected
Gui Add, GroupBox, x16 y60 w480 h60 vGuiBuildSelectionGroupBox, Selected build
Gui Add, GroupBox, x16 y132 w480 h80 vGuiLanguageEditionGroupBox, Language and edition
Gui Add, GroupBox, x16 y226 w480 h88 vGuiSaveOptionsGroupBox, Save options
Gui Add, Edit, x24 y251 w376 h22 vDestinationLocation, %DefaultDir%
Gui Add, Button, x408 y250 w80 h24 gFindFolder vGuiBrowseButton, &Browse...
Gui Add, Checkbox, x24 y282 w224 h24 vProcessSaveUUP gChangeStateOfSkipConversionButton, Save UUPs to "UUPs" subdirectory
Gui Add, Checkbox, x264 y282 w224 h24 vProcessSkipConversion +Disabled, Skip UUP to ISO conversion
Gui Add, Custom, x16 y324 w480 h58 ClassButton +0x200E gStartProcess vStartProcessBtn +Disabled, &Start process`nDownloads selected build and creates ISO image from it

Gosub ChangeToBuildSearchControls

Gui, +Disabled
;Gui Show, w512 h398, %AppName%
Gosub, PrepareEnv
Gui, -Disabled
GuiControl, , AppInfo, Powered by UUP dump API v%APIVersion%
GuiControl, Focus, BuildSearchQuery
Gui Show, w512 h398, %AppName%
Return

HideAllControls:
    GuiControl, Hide, BuildSearchQuery
    GuiControl, Hide, GuiSearchButton
    GuiControl, Hide, GuiSearchGroupBox
    GuiControl, Hide, BuildSelect
    GuiControl, Hide, BuildSelectBtn
    GuiControl, Hide, SelectedBuildText
    GuiControl, Hide, ChangeBuildButton
    GuiControl, Hide, GuiLanguageLabel
    GuiControl, Hide, LangSelect
    GuiControl, Hide, GuiEditionLabel
    GuiControl, Hide, EditionSelect
    GuiControl, Hide, GuiBuildSelectionGroupBox
    GuiControl, Hide, GuiLanguageEditionGroupBox
    GuiControl, Hide, GuiSaveOptionsGroupBox
    GuiControl, Hide, DestinationLocation
    GuiControl, Hide, GuiBrowseButton
    GuiControl, Hide, ProcessSaveUUP
    GuiControl, Hide, ProcessSkipConversion
    GuiControl, Hide, StartProcessBtn

    GuiControl, Disable, BuildSearchQuery
    GuiControl, Disable, GuiSearchButton
    GuiControl, Disable, ChangeBuildButton
    GuiControl, Disable, BuildSelect
    GuiControl, Disable, BuildSelectBtn
    GuiControl, Disable, LangSelect
    GuiControl, Disable, EditionSelect
    GuiControl, Disable, GuiBrowseButton
    GuiControl, Disable, StartProcessBtn
Return

ChangeToConfigControls:
    Gosub HideAllControls
    GuiControl, Show, SelectedBuildText
    GuiControl, Show, ChangeBuildButton
    GuiControl, Show, GuiLanguageLabel
    GuiControl, Show, LangSelect
    GuiControl, Show, GuiEditionLabel
    GuiControl, Show, EditionSelect
    GuiControl, Show, GuiBuildSelectionGroupBox
    GuiControl, Show, GuiLanguageEditionGroupBox
    GuiControl, Show, GuiSaveOptionsGroupBox
    GuiControl, Show, DestinationLocation
    GuiControl, Show, GuiBrowseButton
    GuiControl, Show, ProcessSaveUUP
    GuiControl, Show, ProcessSkipConversion
    GuiControl, Show, StartProcessBtn

    GuiControl, Enable, GuiBrowseButton
Return

ChangeToBuildSearchControls:
    Gosub HideAllControls
    GuiControl, Show, BuildSearchQuery
    GuiControl, Show, GuiSearchButton
    GuiControl, Show, GuiSearchGroupBox
    GuiControl, Show, BuildSelect
    GuiControl, Show, BuildSelectBtn

    GuiControl, Enable, BuildSearchQuery
    GuiControl, Enable, GuiSearchButton
    GuiControl, Enable, BuildSelect
    GuiControl, Enable, BuildSelectBtn
Return

PrepareEnv:
    SetWorkingDir %WorkDir%
    GuiControl, Disable, BuildSelect
    GuiControl, Disable, BuildSelectBtn
    GuiControl, Disable, GuiSearchButton

    FileCreateDir, %WorkDir%\files
    FileInstall, files\splash.png, %WorkDir%\files\splash.png

    SplashImage, %WorkDir%\files\splash.png, ZX52 ZY12 WM400 FM11 FS9 CWFFFFFF AM, 0`%, Preparing... , %AppName%, Segoe UI
    FileInstall, files\7za.exe, %WorkDir%\files\7za.exe

    If(!A_IsCompiled && !FileExist(A_ScriptDir "\files\workdir.7z"))
    {
        FileCopyDir, %A_ScriptDir%\files\workdir, %WorkDir%, 1
    } else {
        FileInstall, files\workdir.7z, %WorkDir%\workdir.7z
        RunWait, %WorkDir%\files\7za.exe x workdir.7z, , Hide
        FileDelete, workdir.7z
    }

    FileInstall, files\converter.7z, %WorkDir%\converter.7z
    RunWait, %WorkDir%\files\7za.exe x converter.7z, , Hide
    FileDelete, converter.7z

    RunWait, %WorkDir%\files\php\php.exe -c files\php\php.ini -r "die(0);", %WorkDir%, UseErrorLevel Hide
    if ErrorLevel <> 0
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

    Run, %WorkDir%\%PhpRunCmd%, %WorkDir%, Hide, PhpPid

    SplashImage, , , 10`%
    Sleep, 1

    URLDownloadToFile, https://gitlab.com/uup-dump/api/-/archive/master/api-master.zip, api.zip
    RunWait, %WorkDir%\files\7za.exe x api.zip, , Hide
    FileMoveDir, api-master, src\api
    FileDelete, api.zip
    SplashImage, , , 55`%
    Sleep, 1

    APIVersion := UrlGet("http://127.0.0.1:" PhpPort "/apiver.php", "GET")

    BuildListResponse := UrlGet("https://uupdump.ml/listid.php", "GET")
    BuildIDs := PopulateBuildList(BuildListResponse)

    SplashImage, , , 100`%

    GuiControl, Enable, BuildSelect
    GuiControl, Enable, BuildSelectBtn
    GuiControl, Enable, GuiSearchButton

    SplashImage, Off
Return

SearchBuilds:
    Gui Submit, NoHide
    NewBuildIDs := PopulateBuildList(BuildListResponse, BuildSearchQuery)

    If NewBuildIDs =
        Return

    BuildIDs := NewBuildIDs
Return

BuildSelectOK:
    if(A_GuiEvent != "Normal")
        Return

    Gui Submit, NoHide
    Gosub ChangeToConfigControls

    GuiControl, Disable, ChangeBuildButton
    GuiControl, Disable, LangSelect
    GuiControl, Disable, EditionSelect
    GuiControl, Disable, StartProcessBtn

    BuildName := BuildNames[BuildSelect]
    GuiControl, , SelectedBuildText, %BuildName%

    SelectedBuild := BuildIDs[BuildSelect]
    if(GetFileInfoForUpdate(SelectedBuild) = 0)
    {
        Gosub ChangeToBuildSearchControls
        Return
    }

    LangCodes := PopulateLangList(SelectedBuild)
    GuiControl, Enable, ChangeBuildButton
    if LangCodes != 0
        Gosub, LangSelected
Return

LangSelected:
    Gui Submit, NoHide
    GuiControl, Disable, ChangeBuildButton
    GuiControl, Disable, EditionSelect
    GuiControl, Disable, StartProcessBtn
    SelectedLang := LangCodes[LangSelect]

    EditionCodes := PopulateEditionList(SelectedBuild, SelectedLang)
    GuiControl, Enable, ChangeBuildButton
    GuiControl, Enable, LangSelect

    if EditionCodes != 0
        Gosub, EditionSelected
Return

EditionSelected:
    Gui Submit, NoHide
    GuiControl, Disable, ChangeBuildButton
    GuiControl, Disable, StartProcessBtn
    SelectedEdition := EditionCodes[EditionSelect]

    GuiControl, Enable, ChangeBuildButton
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

    DownloadScript = "%WorkDir%\aria2_download.cmd"
    if ProcessSkipConversion = 1
        DownloadScript = "%WorkDir%\aria2_download_noconvert.cmd"

    IfNotExist, %DestinationLocation%
    {
        MsgBox, 16, Error, Destination location does not exist.
        Return
    }

    CheckWorkDirLocation(DestinationLocation)

    Gui, +Disabled
    Gui ProgressOfGet: -MinimizeBox -MaximizeBox -SysMenu
    Gui ProgressOfGet: Font, s9, Segoe UI
    Gui ProgressOfGet: Add, Text, x8 y7 w300 h23, Retrieving list of files...
    Gui ProgressOfGet: Add, Progress, x8 y28 w300 h16 -Smooth +0x8 vProgressOfGetProgress, 0
    Gui ProgressOfGet: Show, w316 h52, Please wait...
    SetTimer, UpdateProgressOfGetProgress, 33

    AriaScript := UrlGet("http://127.0.0.1:" PhpPort "/get.php?id=" SelectedBuild "&pack=" SelectedLang "&edition=" SelectedEdition, "GET")

    if(AriaScript == "ERROR")
    {
        Gui ProgressOfGet: Destroy
        MsgBox, 16, Error, Failed to get list of available files. Selected build may be no longer downloadable.
        Gui, -Disabled
        Gui, Show
        Return
    }

    FileDelete, files\aria2_script.txt
    FileAppend, %AriaScript%, files\aria2_script.txt

    Gui, Hide
    Gui, -Disabled
    SetTimer, UpdateProgressOfGetProgress, Off
    Gui ProgressOfGet: Destroy

    RunWait, %ComSpec% /c %DownloadScript% %SpeedLimit%

    if ErrorLevel <> 0
    {
        Progress, Off
        Instruction := "Command prompt window has been closed or an error occurred."
        Content := "Do you want to restart the download and conversion process using files that have been downloaded so far?`n`nIf you choose ""No"" all downloaded files will be removed."

        Result := TaskDialog(Instruction, Content, AppName, 0x6, 0xFFFD)

        If (Result == "Yes") {
            Gosub, StartProcess
            Return
        }

        Gosub, KillApplication
        Return
    }

    Loop, Files, %WorkDir%\*.ISO, F
        MoveFileToLocation(DestinationLocation, A_LoopFileFullPath)

    if ProcessSaveUUP = 1
    {
        FileDelete, %WorkDir%\UUPs\.README

        NewUupDir = %DestinationLocation%\UUPs
        Index := 0
        while(FileExist(NewUupDir))
        {
            Index++
            NewUupDir = %DestinationLocation%\UUPs_%Index%
        }

        IfNotExist, %NewUupDir%
            FileCreateDir, %NewUupDir%

        Loop, Files, %WorkDir%\UUPs\*.*, F
            MoveFileToLocation(NewUupDir, A_LoopFileFullPath)
    }

    Instruction := "Information"
    Content := "Task has been completed."

    TaskDialog(Instruction, Content, AppName, 0x1, 0xFFFD)
    Gosub, KillApplication
Return

GuiClose:
KillApplication:
    Progress, off
    SplashImage, off
    Gui Destroy

    Process, Close, %PhpPid%
    FileRemoveDir, %WorkDir%, 1
    ExitApp
Return

ProgressOfGetGuiClose:
    Return

UpdateProgressOfGetProgress:
    GuiControl ProgressOfGet:, ProgressOfGetProgress, 0
Return

#If WinActive("ahk_pid " CurrentPid)
!D::
    if(!FileExist(WorkDir)) {
        MsgBox, 16, Error, Workdir has not been created yet
        Return
    }
    Run, %A_WinDir%\Explorer.exe %WorkDir%
Return
#If

CreateWorkDir(Loc) {
    Global CurrentDrive, PhpPid

    SplitPath, Loc,,,,, Drive
    CurrentDrive = %Drive%

    Instance := 0
    Loop {
        Instance++
        WorkDir := Drive  "\$UUPDUMP." RandomHex(16)
    } until !FileExist(WorkDir)

    FileCreateDir, %WorkDir%
    FileSetAttrib, +H, %WorkDir%

    IfNotExist, %WorkDir%
    {
        MsgBox, 16, Error, Failed to create working directory.
        ExitApp
    }

    Return WorkDir
}

MoveWorkDir(Loc) {
    Global WorkDir, PhpPid, PhpRunCmd

    Process, Close, %PhpPid%
    NewWorkDir := CreateWorkDir(Loc)

    FileCopyDir, %WorkDir%, %NewWorkDir%, 1
    SetWorkingDir %NewWorkDir%
    FileRemoveDir, %WorkDir%, 1

    WorkDir := NewWorkDir
    Run, %WorkDir%\%PhpRunCmd%, %WorkDir%, Hide, PhpPid
}

FindFolder() {
    Gui, +Disabled
    FileSelectFolder, DestinationLocation, , 3, Browse for destination location of ISO image
    Gui, -Disabled
    Gui, Show

    if DestinationLocation =
        Return

    GuiControl, , DestinationLocation, %DestinationLocation%
    CheckWorkDirLocation(DestinationLocation)
}

CheckWorkDirLocation(DestinationLocation) {
    IfNotExist, %DestinationLocation%
    {
        MsgBox, 16, Error, Destination location does not exist.
        Return
    }

    Global CurrentDrive
    SplitPath, DestinationLocation,,,,, SelectedDrive
    If SelectedDrive =
    {
        MsgBox, 16, Error, An error has occurred during attempt to move working directory.
        Return
    }

    if(SelectedDrive <> CurrentDrive)
    {
        Gui, +Disabled
        Progress, 0 FM12 WM400 C00 ZH0 AM, , Moving working directory..., Please wait..., Segoe UI
        MoveWorkDir(SelectedDrive)
        Gui, -Disabled
        Progress, Off
    }
}

PopulateBuildList(Response, Search = "") {
    Global BuildNames

    Response := RegExReplace(Response, "i)Cumulative Update for ", "Update to ")

    Search := RegExReplace(Search, "([\/\\+\*\?\[\^\]\$\(\)\{\}\=\!\<\>\|\:\-])", "\$1")
    Search := RegExReplace(Search, " ", ".*")

    BuildList =
    BuildIDs := []
    BuildNames := []

    Index = 0
    Loop, Parse, Response, `n
    {
        RegExMatch(A_LoopField, "SO)(.*)\|(.*)\|(.*)\|(.*)", Match)
        Build := Match.1
        Arch := Match.2
        ID := Match.3
        Name := Match.4

        if !RegExMatch(Name " " Arch, "i)" Search)
            Continue

        Index++

        if ID !=
        {
            BuildIDs[Index] := ID
            BuildNames[Index] := Name " " Arch
            BuildList .= Name " " Arch "|"
            if(Index = 1)
            {
                BuildList .= "|"
            }
        }
    }

    if (BuildList == "" && Search == "")
    {
        MsgBox, 16, Error, Cannot retrieve list of available builds.
        Gosub, KillApplication
    }

    if (BuildList == "")
    {
        MsgBox, 16, Error, There are no builds available for your search.
        Return
    }

    GuiControl, , BuildSelect, |
    GuiControl, , BuildSelect, %BuildList%
    Return BuildIDs
}

PopulateLangList(SelectedBuild) {
    Global PhpPort
    Output := UrlGet("http://127.0.0.1:" PhpPort "/listlangs.php?id=" SelectedBuild, "GET")

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
    Global LangCodes, LangSelect, PhpPort

    Output := UrlGet("http://127.0.0.1:" PhpPort "/listeditions.php?id=" SelectedBuild "&pack=" Lang, "GET")

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

    IfNotExist src\fileinfo
    {
        FileCreateDir src\fileinfo
    }

    IfNotExist src\fileinfo\%Update%.json
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
        URLDownloadToFile, https://gitlab.com/uup-dump/fileinfo/raw/master/%Update%.json, src\fileinfo\%Update%.json
    }

    Progress, 5001
    Progress, 5000, , Retrieving packs...

    IfNotExist src\packs
    {
        FileCreateDir src\packs
    }

    IfNotExist src\packs\%Update%.json.gz
    {
        Response := UrlGet("https://gitlab.com/uup-dump/packs/raw/master/" Update ".json.gz", "HEAD")

        if(Response = 200)
        {
            Progress, 6001
            Progress, 6000
            URLDownloadToFile, https://gitlab.com/uup-dump/packs/raw/master/%Update%.json.gz, src\packs\%Update%.json.gz
        }
    }

    Progress, 10001
    Progress, 10000

    Gui, -Disabled
    Progress, off
}

MoveFileToLocation(Dest, File) {
    Global AppName
    SplitPath, File, FileName, FileDir, FileExt, FileNoExt

    NewFile = %Dest%\%FileName%
    Index := 0
    while(FileExist(NewFile))
    {
        Index++
        NewFile = %Dest%\%FileNoExt%_%Index%.%FileExt%
    }

    FileMove, %File%, %NewFile%
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
    WebRequest := ComObjCreate("MSXML2.ServerXMLHTTP.6.0")
    WebRequest.Open(Method, URL, true)
    WebRequest.setRequestHeader("User-Agent", UserAgent)
    WebRequest.Send()

    while(WebRequest.readyState != 4)
        Sleep, 10

    if(Method = "HEAD")
        Return WebRequest.Status

    Return WebRequest.ResponseText
}

RandomHex(Num) {
    Chars = 0123456789abcdef
    MaxChars := StrLen(Chars)

    String := ""
    Loop %Num%
    {
        Random, rand, 0, MaxChars
        String .= SubStr(Chars, rand, 1)
    }

    Return String
}
