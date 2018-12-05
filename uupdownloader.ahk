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
File_Version=1.1.0.4
Inc_File_Version=0
Legal_Copyright=(c) 2018 UUP dump authors
Product_Name=UUP dump downloader
Product_Version=1.1.0.4
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

Version = 1.1.0-alpha.4
AppNameOnly = UUP dump downloader

AppName = %AppNameOnly% v%version%
UserAgent = %AppNameOnly%/%version%

DefaultLanguage = en-US

Translation := []
Translation["NoAdmin"] := "This application requires to be run as an administrator."
Translation["UnsupportedSystem"] := "This application requires Windows 7 or later."
Translation["NoADK"] := "We've detected that you are using older version of Windows without having Windows 10 ADK installed. Due to this the resulting ISO image may be created incorrectly.`n`nTo ensure that the process is successful, please install Windows 10 ADK or use this application on Windows 10.`n`nDo you want to continue?"
Translation["BackendTestFailed"] := "PHP backend test failed. Without this backend working this application cannot continue to operate.`n`nWhat does this mean?`n - You don't have Visual C++ Redistributable 2015 x86 installed`n - Your antivirus is interfering with the process`n`nIf problem persists:`n - Install Visual C++ Redistributable 2015 x86`n - Please disable your antivirus solution temporarily`n`nThe application will close."
Translation["Preparing"] := "Preparing..."
Translation["PrepareToWork"] := "Preparing application to work..."
Translation["Search"] := "&Search"
Translation["SearchBuilds"] := "Search builds"
Translation["BuildSelectAction"] := "&Choose selected build"
Translation["BuildSelectActionSub"] := "Shows language, edition, and destination location selection page"
Translation["PoweredBy"] := "Powered by"
Translation["Change"] := "&Change"
Translation["Language"] := "Language"
Translation["Edition"] := "Edition"
Translation["SelectedBuild"] := "Selected build"
Translation["LanguageAndEdition"] := "Language and edition"
Translation["SaveOptions"] := "Save options"
Translation["Browse"] := "&Browse..."
Translation["SaveUUPFiles"] := "Save UUPs to ""UUPs"" subdirectory"
Translation["SkipConversion"] := "Skip UUP to ISO conversion"
Translation["StartProcess"] := "&Start process"
Translation["StartProcessSub"] := "Downloads selected build and creates ISO image from it"
Translation["RetrievingListOfFiles"] := "Retrieving list of files..."
Translation["BuildNotDownloadable"] := "Failed to get list of available files. Selected build may be no longer downloadable."
Translation["CommandPromptClosed"] := "Command prompt window has been closed or an error occurred."
Translation["CommandPromptClosedQuestion"] := "Do you want to restart the download and conversion process using files that have been downloaded so far?`n`nIf you choose ""No"" all downloaded files will be removed."
Translation["Information"] := "Information"
Translation["TaskCompleted"] := "Task has been completed."
Translation["WorkDirNotCreatedYet"] := "Workdir has not been created yet"
Translation["CreateDirFail"] := "Failed to create working directory."
Translation["BrowseForLocation"] := "Browse for destination location of ISO image"
Translation["DestinationLocationNotExists"] := "Destination location does not exist."
Translation["WorkDirMoveError"] := "An error has occurred during attempt to move working directory."
Translation["PleaseWait"] := "Please wait..."
Translation["Error"] := "Error"
Translation["MovingWorkDir"] := "Moving working directory..."
Translation["CannotGetBuilds"] := "Cannot retrieve list of available builds."
Translation["NoSearchResults"] := "There are no builds available for your search."
Translation["NoLanguages"] := "There are no languages available for this selection."
Translation["AllEditions"] := "All editions"
Translation["NoEditions"] := "There are no editions available for this selection."
Translation["RetrievingFileInfo"] := "Retrieving fileinfo..."
Translation["NoFileinfo"] := "Fileinfo database does not exist for this selection."
Translation["RetrievingPacks"] := "Retrieving packs..."

Languages := []
Languages["ar-sa"] := "Arabic (Saudi Arabia)"
Languages["bg-bg"] := "Bulgarian"
Languages["cs-cz"] := "Czech"
Languages["da-dk"] := "Danish"
Languages["de-de"] := "German"
Languages["el-gr"] := "Greek"
Languages["en-gb"] := "English (United Kingdom)"
Languages["en-us"] := "English (United States)"
Languages["es-es"] := "Spanish (Spain)"
Languages["es-mx"] := "Spanish (Mexico)"
Languages["et-ee"] := "Estonian"
Languages["fi-fi"] := "Finnish"
Languages["fr-ca"] := "French (Canada)"
Languages["fr-fr"] := "French (France)"
Languages["he-il"] := "Hebrew"
Languages["hr-hr"] := "Croatian"
Languages["hu-hu"] := "Hungarian"
Languages["it-it"] := "Italian"
Languages["ja-jp"] := "Japanese"
Languages["ko-kr"] := "Korean"
Languages["lt-lt"] := "Lithuanian"
Languages["lv-lv"] := "Latvian"
Languages["nb-no"] := "Norwegian (Bokmal)"
Languages["nl-nl"] := "Dutch"
Languages["pl-pl"] := "Polish"
Languages["pt-br"] := "Portuguese (Brazil)"
Languages["pt-pt"] := "Portuguese (Portugal)"
Languages["ro-ro"] := "Romanian"
Languages["ru-ru"] := "Russian"
Languages["sk-sk"] := "Slovak"
Languages["sl-si"] := "Slovenian"
Languages["sr-latn-rs"] := "Serbian (Latin)"
Languages["sv-se"] := "Swedish"
Languages["th-th"] := "Thai"
Languages["tr-tr"] := "Turkish"
Languages["uk-ua"] := "Ukrainian"
Languages["zh-cn"] := "Chinese (Simplified)"
Languages["zh-tw"] := "Chinese (Traditional)"

RegRead, Locale, HKEY_CURRENT_USER\Control Panel\International, LocaleName

If(Locale == "pl-PL")
    FileInstall, files\lang\pl-PL.ini, %A_Temp%\UUPDUMP_translation.ini

If(Locale == "nl-NL")
    FileInstall, files\lang\nl-NL.ini, %A_Temp%\UUPDUMP_translation.ini

If(FileExist(A_ScriptDir "\UUPDUMP_translation.ini"))
    FileCopy, %A_ScriptDir%\UUPDUMP_translation.ini, %A_Temp%\UUPDUMP_translation.ini, 1

If(FileExist(A_Temp "\UUPDUMP_translation.ini"))
{
    For Key, Value in Translation
    {
        IniRead, text_%Key%, %A_Temp%\UUPDUMP_translation.ini, Translations, %Key%, MissingTranslation
        If(text_%Key% == "MissingTranslation")
        {
            text_%Key% := Value
        } else {
            text_%Key% := StrReplace(text_%Key%, "\n", "`n")
            text_%Key% := StrReplace(text_%Key%, "\`n", "\n")
        }
    }
    For Key in Languages
    {
        IniRead, Name, %A_Temp%\UUPDUMP_translation.ini, Languages, %Key%, MissingTranslation
        If(Name != "MissingTranslation")
        {
            Languages[Key] := Name
        }
    }
    Name := ""
    IniRead, DefaultLanguage, %A_Temp%\UUPDUMP_translation.ini, Config, Language, MissingTranslation
    If(Name == "MissingTranslation")
    {
        DefaultLanguage = en-US
    }

    FileDelete, %A_Temp%\UUPDUMP_translation.ini
} else {
    For Key, Value in Translation
    {
        text_%Key% := Value
    }
}

Translation := ""

If !A_IsCompiled
{
    Menu, Tray, Icon, %A_ScriptDir%\files\icon.ico
}

Gui, +OwnDialogs

if A_IsAdmin = 0
{
    MsgBox, 16, %AppName%, %text_NoAdmin%
    ExitApp
}

if A_OSVersion in WIN_NT4,WIN_95,WIN_98,WIN_ME,WIN_2000,WIN_XP,WIN_2003,WIN_VISTA
{
    MsgBox, 16, %AppName%, %text_UnsupportedSystem%
    ExitApp
}

if A_OSVersion in WIN_7,WIN_8,WIN_8.1
{
RegRead, KitsRootWow, HKLM\Software\Wow6432Node\Microsoft\Windows Kits\Installed Roots, KitsRoot10
RegRead, KitsRoot, HKLM\Software\Microsoft\Windows Kits\Installed Roots, KitsRoot10

if (KitsRoot == "" && KitsRootWow == "")
    MsgBox, 68, %AppName%, %text_NoADK%
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
Gui Add, Text, x16 y31 w480 h23 BackgroundTrans vAppInfo, %text_PrepareToWork%
Gui Font
Gui Font, s9, Segoe UI

;Build search controls
Gui Add, Edit, x24 y85 w376 vBuildSearchQuery
Gui Add, Button, x408 y84 w80 h25 gSearchBuilds vGuiSearchButton +Default, %text_Search%
Gui Add, GroupBox, x16 y60 w480 h256 vGuiSearchGroupBox, %text_SearchBuilds%
Gui Add, ListBox, x24 y120 w464 h186 +0x100 +AltSubmit +Disabled vBuildSelect
Gui Add, Custom, x16 y324 w480 h58 gBuildSelectOK vBuildSelectBtn ClassButton +0x200E +Disabled, %text_BuildSelectAction%`n%text_BuildSelectActionSub%

;Language, edition, destination location controls
Gui Add, Edit, x24 y85 w376 +ReadOnly vSelectedBuildText
Gui Add, Button, x408 y84 w80 h25 gChangeToBuildSearchControls vChangeBuildButton, %text_Change%
Gui Add, Text, x24 y152 w224 h23 vGuiLanguageLabel, %text_Language%
Gui Add, DropDownList, x24 y175 w224 +AltSubmit +Disabled vLangSelect gLangSelected
Gui Add, Text, x264 y152 w224 h23 vGuiEditionLabel, %text_Edition%
Gui Add, DropDownList, x264 y175 w224 +AltSubmit +Disabled vEditionSelect gEditionSelected
Gui Add, GroupBox, x16 y60 w480 h60 vGuiBuildSelectionGroupBox, %text_SelectedBuild%
Gui Add, GroupBox, x16 y132 w480 h80 vGuiLanguageEditionGroupBox, %text_LanguageAndEdition%
Gui Add, GroupBox, x16 y226 w480 h88 vGuiSaveOptionsGroupBox, %text_SaveOptions%
Gui Add, Edit, x24 y251 w376 h22 vDestinationLocation, %DefaultDir%
Gui Add, Button, x408 y250 w80 h24 gFindFolder vGuiBrowseButton, %text_Browse%
Gui Add, Checkbox, x24 y282 w224 h24 vProcessSaveUUP gChangeStateOfSkipConversionButton, %text_SaveUUPFiles%
Gui Add, Checkbox, x264 y282 w224 h24 vProcessSkipConversion +Disabled, %text_SkipConversion%
Gui Add, Custom, x16 y324 w480 h58 ClassButton +0x200E gStartProcess vStartProcessBtn +Disabled, %text_StartProcess%`n%text_StartProcessSub%

Gosub ChangeToBuildSearchControls

Gui, +Disabled
;Gui Show, w512 h398, %AppName%
Gosub, PrepareEnv
Gui, -Disabled
GuiControl, , AppInfo, %text_PoweredBy% UUP dump API v%APIVersion%
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

    SplashImage, %WorkDir%\files\splash.png, ZX52 ZY12 WM400 FM11 FS9 CWFFFFFF AM, 0`%, %text_Preparing% , %AppName%, Segoe UI
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
        MsgBox, 16, %text_Error%, %text_BackendTestFailed%
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
        MsgBox, 16, %text_Error%, %text_DestinationLocationNotExists%
        Return
    }

    CheckWorkDirLocation(DestinationLocation)

    Gui, +Disabled
    Gui ProgressOfGet: -MinimizeBox -MaximizeBox -SysMenu
    Gui ProgressOfGet: Font, s9, Segoe UI
    Gui ProgressOfGet: Add, Text, x8 y7 w300 h23, %text_RetrievingListOfFiles%
    Gui ProgressOfGet: Add, Progress, x8 y28 w300 h16 -Smooth +0x8 vProgressOfGetProgress, 0
    Gui ProgressOfGet: Show, w316 h52, %text_PleaseWait%
    SetTimer, UpdateProgressOfGetProgress, 33

    AriaScript := UrlGet("http://127.0.0.1:" PhpPort "/get.php?id=" SelectedBuild "&pack=" SelectedLang "&edition=" SelectedEdition, "GET")

    if(AriaScript == "ERROR")
    {
        Gui ProgressOfGet: Destroy
        MsgBox, 16, %text_Error%, %text_BuildNotDownloadable%
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
        Instruction := text_CommandPromptClosed
        Content := text_CommandPromptClosedQuestion

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

    Instruction := text_Information
    Content := text_TaskCompleted

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
        MsgBox, 16, %text_Error%, %text_WorkDirNotCreatedYet%
        Return
    }
    Run, %A_WinDir%\Explorer.exe %WorkDir%
Return
#If

CreateWorkDir(Loc) {
    Global CurrentDrive, PhpPid, text_CreateDirFail, text_Error

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
        MsgBox, 16, %text_Error%, %text_CreateDirFail%
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
    Global text_BrowseForLocation

    Gui, +Disabled
    FileSelectFolder, DestinationLocation, , 3, %text_BrowseForLocation%
    Gui, -Disabled
    Gui, Show

    if DestinationLocation =
        Return

    GuiControl, , DestinationLocation, %DestinationLocation%
    CheckWorkDirLocation(DestinationLocation)
}

CheckWorkDirLocation(DestinationLocation) {
    Global text_DestinationLocationNotExists, text_WorkDirMoveError, text_MovingWorkDir, text_PleaseWait, text_Error

    IfNotExist, %DestinationLocation%
    {
        MsgBox, 16, %text_Error%, %text_DestinationLocationNotExists%
        Return
    }

    Global CurrentDrive
    SplitPath, DestinationLocation,,,,, SelectedDrive
    If SelectedDrive =
    {
        MsgBox, 16, %text_Error%, %text_WorkDirMoveError%
        Return
    }

    if(SelectedDrive <> CurrentDrive)
    {
        Gui, +Disabled
        Progress, 0 FM12 WM400 C00 ZH0 AM, , %text_MovingWorkDir%, %text_PleaseWait%, Segoe UI
        MoveWorkDir(SelectedDrive)
        Gui, -Disabled
        Progress, Off
    }
}

PopulateBuildList(Response, Search = "") {
    Global BuildNames, text_Error, text_CannotGetBuilds, text_NoSearchResults

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
        MsgBox, 16, %text_Error%, %text_CannotGetBuilds%
        Gosub, KillApplication
    }

    if (BuildList == "")
    {
        MsgBox, 16, %text_Error%, %text_NoSearchResults%
        Return
    }

    GuiControl, , BuildSelect, |
    GuiControl, , BuildSelect, %BuildList%
    Return BuildIDs
}

PopulateLangList(SelectedBuild) {
    Global PhpPort, text_Error, text_NoLanguages, Languages, DefaultLanguage
    Output := UrlGet("http://127.0.0.1:" PhpPort "/listlangs.php?id=" SelectedBuild, "GET")

    GuiControl, , LangSelect, |
    LangList =
    TranslatedList =
    LangCodes := []
    Langs := []
    DefLang := Format("{:l}", DefaultLanguage)
    ContainsDefaultLang = 0

    Loop, Parse, Output, `n
    {
        RegExMatch(A_LoopField, "SO)(.*)\|(.*)", Match)
        Code := Match.1
        Lang := Match.2

        If(Languages[Code] = "")
        {
            TranslatedList .= Lang "|" Code "`n"
        } else {
            TranslatedList .= Languages[Code] "|" Code "`n"
        }

        if(Code = DefLang)
            ContainsDefaultLang = 1
    }

    Sort, TranslatedList, CL

    Index := 0
    Loop, Parse, TranslatedList, `n
    {
        RegExMatch(A_LoopField, "SO)(.*)\|(.*)", Match)
        Lang := Match.1
        Code := Match.2

        if Code !=
        {
            Index++
            LangCodes[Index] := Code
            If(Languages[Code] = "")
            {
                LangList .= Lang "|"
            } else {
                LangList .= Languages[Code] "|"
            }

            if(ContainsDefaultLang = 1 && Code = DefLang)
            {
                LangList .= "|"
            }
            else if(ContainsDefaultLang = 0 && Index = 1)
            {
                LangList .= "|"
            }
        }
    }

    if(LangList = "")
    {
        MsgBox, 16, %text_Error%, %text_NoLanguages%
        Return 0
    }

    GuiControl, , LangSelect, %LangList%
    GuiControl, Enable, LangSelect

    Return LangCodes
}

PopulateEditionList(SelectedBuild, Lang) {
    Global LangCodes, LangSelect, PhpPort, text_Error, text_NoEditions, text_AllEditions

    Output := UrlGet("http://127.0.0.1:" PhpPort "/listeditions.php?id=" SelectedBuild "&pack=" Lang, "GET")

    Gui, Submit, NoHide
    SelectedLang := LangCodes[LangSelect]

    If(Lang != SelectedLang)
        Return PopulateEditionList(SelectedBuild, SelectedLang)

    GuiControl, , EditionSelect, |
    EditionList =
    EditionCodes := []
    EditionCodes[1] := 0

    Index := 1
    Loop, Parse, Output, `n
    {
        RegExMatch(A_LoopField, "SO)(.*)\|(.*)", Match)
        Code := Match.1
        Edition := Match.2

        if Code !=
        {
            Index++
            EditionCodes[Index] := Code
            EditionList .= Edition "|"
        }
    }

    if EditionList =
    {
        MsgBox, 16, %text_Error%, %text_NoEditions%
        Return 0
    }

    EditionList = %text_AllEditions%||%EditionList%
    GuiControl, , EditionSelect, %EditionList%
    GuiControl, Enable, EditionSelect

    Return EditionCodes
}

GetFileInfoForUpdate(Update) {
    Global text_PleaseWait, text_Error, text_RetrievingFileinfo, text_NoFileinfo, text_RetrievingPacks
    Progress, 0 WM400 C00 ZH16 AM R0-10001, , %text_RetrievingFileinfo%, %text_PleaseWait%, Segoe UI
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
            MsgBox, 16, %text_Error%, %text_NoFileinfo%
            Gui, -Disabled
            Progress, Off
            Return 0
        }
        Progress, 1001
        Progress, 1000
        URLDownloadToFile, https://gitlab.com/uup-dump/fileinfo/raw/master/%Update%.json, src\fileinfo\%Update%.json
    }

    Progress, 5001
    Progress, 5000, , %text_RetrievingPacks%

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
