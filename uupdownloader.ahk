#Include %A_ScriptDir%\include\header.ahk
#Include %A_ScriptDir%\include\appinfo.ahk

If(ReleaseType == 0)
{
    VersionCheckSnippet = 1792654
}
else If(ReleaseType == 1)
{

    VersionCheckSnippet = 1792655
}
else
{

    VersionCheckSnippet = 1798502
}

VersionCheckUrl = https://gitlab.com/uup-dump/downloader/snippets/%VersionCheckSnippet%/raw

If(A_IsCompiled)
{
    MsgBox, 16, Unsupported build, The application was built in unsupported way. Please read build instructions in readme.`n`nThe application will be terminated.
    ExitApp
}

If(ParentExe != "")
{
    SplitPath, ParentExe,, ScriptDir,, ScriptNameNoExt
} else {
    SplitPath, A_ScriptFullPath,, ScriptDir,, ScriptNameNoExt
}

#Include %A_ScriptDir%\include\language.ahk

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

#Include %A_ScriptDir%\include\functions.ahk

if(A_Is64bitOS == 1 && A_PtrSize == 4)
{
    CmdPath = "%A_WinDir%\Sysnative\cmd.exe"
} else {
    CmdPath = "%A_WinDir%\System32\cmd.exe"
}

CurrentPid := DllCall("GetCurrentProcessId")
Random, PhpPort, 49152, 65535
PhpRunCmd = files\php\php.exe -c "%A_ScriptDir%\files\php\php.ini" -S 127.0.0.1:%PhpPort% -t src

IniConfig := ScriptDir "\" ScriptNameNoExt ".ini"
DefaultDir := ScriptDir
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

Color := GetCurrentSystemColor()

;Header
Gui Add, Text, x0 y0 w512 h54 +0x6
Gui Font, s11 q5 c%Color%, Segoe UI
Gui Add, Text, x16 y7 w480 r1 BackgroundTrans vAppNameText, %AppName%
Gui Font, s9 q5 cDefault
Gui Add, Text, x16 y31 w480 r1 BackgroundTrans vAppInfo, %text_PrepareToWork%
Gui Font
Gui Font, s9 q5, Segoe UI

;Build search controls
Gui Font, s10 q5
Gui Add, GroupBox, x16 y60 w480 h254 vGuiSearchGroupBox, %text_SearchBuilds%
Gui Font, s9 q5
Gui Add, Edit, x24 y85 w376 vBuildSearchQuery
Gui Add, Button, x408 y84 w80 h25 gSearchBuilds vGuiSearchButton +Default, %text_Search%
Gui Add, ListBox, x24 y120 w464 h184 +0x100 +AltSubmit +Disabled vBuildSelect
Gui Add, Custom, x16 y324 w480 h64 gBuildSelectOK vBuildSelectBtn ClassButton +0x200E +Disabled, %text_BuildSelectAction%`n%text_BuildSelectActionSub%

;Language, edition, destination location controls
Gui Font, s10 q5
Gui Add, GroupBox, x16 y60 w480 h60 vGuiBuildSelectionGroupBox, %text_SelectedBuild%
Gui Add, GroupBox, x16 y132 w480 h80 vGuiLanguageEditionGroupBox, %text_LanguageAndEdition%
Gui Add, GroupBox, x16 y226 w480 h88 vGuiSaveOptionsGroupBox, %text_SaveOptions%
Gui Font, s9 q5
Gui Add, Edit, x24 y85 w376 +ReadOnly vSelectedBuildText
Gui Add, Button, x408 y84 w80 h25 gChangeToBuildSearchControls vChangeBuildButton, %text_Change%
Gui Add, Text, x24 y154 w224 r1 vGuiLanguageLabel, %text_Language%
Gui Add, DropDownList, x24 y175 w224 +AltSubmit +Disabled vLangSelect gLangSelected
Gui Add, Text, x264 y154 w224 r1 vGuiEditionLabel, %text_Edition%
Gui Add, DropDownList, x264 y175 w224 +AltSubmit +Disabled vEditionSelect gEditionSelected
Gui Add, Edit, x24 y251 w376 h22 vDestinationLocation, %DefaultDir%
Gui Add, Button, x408 y250 w80 h24 gFindFolder vGuiBrowseButton, %text_Browse%
Gui Add, Checkbox, x24 y278 w224 h32 vProcessSaveUUP gChangeStateOfSkipConversionButton, %text_SaveUUPFiles%
Gui Add, Checkbox, x264 y278 w224 h32 vProcessSkipConversion +Disabled, %text_SkipConversion%
Gui Add, Custom, x16 y324 w480 h64 ClassButton +0x200E gStartProcess vStartProcessBtn +Disabled, %text_StartProcess%`n%text_StartProcessSub%

;Information text
Gui Add, Text, x0 y398 w515 h1 +0x10
Gui Add, Picture, x4 y404 w16 h16 Icon5, user32.dll
Gui Add, Link, x24 y404 w480 r1 vBottomInformationText gBottomInformationAction, %text_PleaseSelectBuild%

If(InStr(A_OSVersion, "10.0")) {
    OnMessage(0x320, "DWMColorChangedEvent")
}

Gosub ChangeToBuildSearchControls

Gui, +Disabled
Gosub, PrepareEnv
Gui, -Disabled

GuiControl, , AppInfo, %text_PoweredBy% UUP dump API v%APIVersion%
GuiControl, Focus, BuildSearchQuery
Gui Show, w512 h424, %AppName%
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
    GuiControl,, BottomInformationText, %text_PleaseSelectBuild%
Return

PrepareEnv:
    SetWorkingDir %WorkDir%
    GuiControl, Disable, BuildSelect
    GuiControl, Disable, BuildSelectBtn
    GuiControl, Disable, GuiSearchButton

    SplashImage, %A_ScriptDir%\files\splash.png, ZX52 ZY12 WM400 FM11 FS9 CWFFFFFF AM, 0`%, %text_Preparing% , %AppName%, Segoe UI
    FileCopyDir, %A_ScriptDir%\files\workdir, %WorkDir%, 1
    RunWait, %A_ScriptDir%\files\7za.exe x "%A_ScriptDir%\files\converter.7z", %WorkDir%, Hide

    RunWait, %A_ScriptDir%\files\php\php.exe -c "%A_ScriptDir%\files\php\php.ini" -r "die(0);", %WorkDir%, UseErrorLevel Hide
    if ErrorLevel <> 0
    {
        MsgBox, 16, %text_Error%, %text_BackendTestFailed%
        gosub, KillApplication
    }

    Run, %A_ScriptDir%\%PhpRunCmd%, %WorkDir%, Hide, PhpPid

    SplashImage, , , 10`%
    Sleep, 1

    URLDownloadToFile, https://gitlab.com/uup-dump/api/-/archive/master/api-master.zip, api.zip
    RunWait, %A_ScriptDir%\files\7za.exe x api.zip, , Hide
    FileMoveDir, api-master, src\api
    FileDelete, api.zip
    SplashImage, , , 55`%
    Sleep, 1

    APIVersion := UrlGet("http://127.0.0.1:" PhpPort "/apiver.php", "GET")

    BuildListResponse := UrlGet("https://uupdump.ml/listid.php", "GET")
    BuildIDs := PopulateBuildList(BuildListResponse)
    SplashImage, , , 90`%

    UpdateAvailable := CheckVersion(Version, VersionCheckUrl)

    PhpWasRunning := 1
    SetTimer, MonitorPhp, 100

    SplashImage, , , 100`%

    GuiControl, Enable, BuildSelect
    GuiControl, Enable, BuildSelectBtn
    GuiControl, Enable, GuiSearchButton

    SplashImage, Off
Return

SearchBuilds:
    Gui Submit, NoHide
    NewBuildIDs := PopulateBuildList(BuildListResponse, BuildSearchQuery)

    If(NewBuildIDs == "")
        Return

    BuildIDs := NewBuildIDs
Return

BuildSelectOK:
    if(A_GuiEvent != "Normal")
        Return

    Gui Submit, NoHide
    Gosub ChangeToConfigControls
    GuiControl,, BottomInformationText, %text_PleaseWait%

    GuiControl, Disable, ChangeBuildButton
    GuiControl, Disable, LangSelect
    GuiControl, Disable, EditionSelect
    GuiControl, Disable, StartProcessBtn

    BuildName := BuildNames[BuildSelect]
    BuildArch := BuildArchs[BuildSelect]
    BuildNumber := BuildNumbers[BuildSelect]
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
    GuiControl,, BottomInformationText, %text_PleaseWait%

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
    GuiControl,, BottomInformationText, %text_PleaseWait%

    SelectedEdition := EditionCodes[EditionSelect]
    FilesSize := GetFilesSize(SelectedBuild, SelectedLang, SelectedEdition)

    UpdatesList := UrlGet("http://127.0.0.1:" PhpPort "/getlist.php?id=" SelectedBuild "&pack=" SelectedLang "&edition=updateOnly", "GET")
    If(UpdatesList != "ERROR")
    {
        UpdatesList := RegExReplace(UpdatesList, "`n", "`r`n")
        UpdatesList := RegExReplace(UpdatesList, "\|.*")
        UpdatesList := RegExReplace(UpdatesList, "(.+)`r`n", " - $1`r`n")

        GuiControl,, BottomInformationText, %text_DownloadSize%: %FilesSize% <a id="ShowIncludedUpdatesList">%text_ContainsAdditionalUpdates%</a>
    } else {
        GuiControl,, BottomInformationText, %text_DownloadSize%: %FilesSize%
    }

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

    RunWait, %CmdPath% /c %DownloadScript% %SpeedLimit%

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
        BuildHash := SubStr(SelectedBuild, 1, 8)

        SelEditFolder := SelectedEdition
        If(SelEditFolder == 0)
        {
            SelEditFolder = all
        }

        FolderName = %BuildNumber%_%BuildArch%_%SelectedLang%_%SelEditFolder%_%BuildHash%
        NewUupDir = %DestinationLocation%\UUPs\%FolderName%

        Index := 0
        while(FileExist(NewUupDir))
        {
            Index++
            NewUupDir = %DestinationLocation%\UUPs\%FolderName%_%Index%
        }

        IfNotExist, %NewUupDir%
            FileCreateDir, %NewUupDir%

        FileDelete, %WorkDir%\UUPs\.README
        Loop, Files, %WorkDir%\UUPs\*.*, F
            MoveFileToLocation(NewUupDir, A_LoopFileFullPath)
    }

    Instruction := text_Information
    Content := text_TaskCompleted

    TaskDialog(Instruction, Content, AppName, 0x1, 0xFFFD)
    Gosub, KillApplication
Return

MonitorPhp:
    Process, Exist, %PhpPid%
    If(%ErrorLevel% == 0)
    {
        Run, %A_ScriptDir%\%PhpRunCmd%, %WorkDir%, Hide, PhpPid

        Sleep, 100
        Process, Exist, %PhpPid%

        If(%ErrorLevel% == 0)
        {
            MsgBox, 16, %text_Error%, %text_PhpFailedRestart%
            Gosub KillApplication
            Return
        }
    }
Return

GuiClose:
KillApplication:
    SetTimer, MonitorPhp, Off
    Progress, off
    SplashImage, off
    Gui Destroy

    i := 0
    ProcessKilled := 0

    while(i < 10) {
        Process, Close, %PhpPid%

        If(%ErrorLevel% != 0)
        {
            ProcessKilled := 1
            break
        }

        i++
    }

    If(ProcessKilled = 0 && PhpWasRunning)
    {
        MsgBox, 16, %text_Error%, %text_PhpFailedClose%
    }

    FileRemoveDir, %WorkDir%, 1
    ExitApp
Return

ProgressOfGetGuiClose:
    Return

UpdateProgressOfGetProgress:
    GuiControl ProgressOfGet:, ProgressOfGetProgress, 0
Return

BottomInformationAction:
    If(ErrorLevel == "ShowIncludedUpdatesList")
    {
        MsgBox, 48, %AppName%, %text_UpdatesIncludedInfo1%:`n%UpdatesList%`n%text_UpdatesIncludedInfo2%
    }
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
