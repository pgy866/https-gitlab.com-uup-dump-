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
File_Version=1.1.0.8
Inc_File_Version=0
Legal_Copyright=(c) 2018 UUP dump authors
Product_Name=UUP dump downloader
Product_Version=1.1.0.8
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

Version = 1.1.0-alpha.8
AppNameOnly = UUP dump downloader

AppName = %AppNameOnly% v%version%
UserAgent = %AppNameOnly%/%version%

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

if A_OSVersion in WIN_7,WIN_8,WIN_8.1
{
RegRead, KitsRootWow, HKLM\Software\Wow6432Node\Microsoft\Windows Kits\Installed Roots, KitsRoot10
RegRead, KitsRoot, HKLM\Software\Microsoft\Windows Kits\Installed Roots, KitsRoot10

if (KitsRoot == "" && KitsRootWow == "")
    MsgBox, 68, %AppName%, %text_NoADK%
    IfMsgBox, No
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
Gui Add, GroupBox, x16 y60 w480 h254 vGuiSearchGroupBox, %text_SearchBuilds%
Gui Add, ListBox, x24 y120 w464 h184 +0x100 +AltSubmit +Disabled vBuildSelect
Gui Add, Custom, x16 y324 w480 h64 gBuildSelectOK vBuildSelectBtn ClassButton +0x200E +Disabled, %text_BuildSelectAction%`n%text_BuildSelectActionSub%

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
Gui Add, Checkbox, x24 y278 w224 h32 vProcessSaveUUP gChangeStateOfSkipConversionButton, %text_SaveUUPFiles%
Gui Add, Checkbox, x264 y278 w224 h32 vProcessSkipConversion +Disabled, %text_SkipConversion%
Gui Add, Custom, x16 y324 w480 h64 ClassButton +0x200E gStartProcess vStartProcessBtn +Disabled, %text_StartProcess%`n%text_StartProcessSub%

Gosub ChangeToBuildSearchControls

Gui, +Disabled
Gosub, PrepareEnv
Gui, -Disabled
GuiControl, , AppInfo, %text_PoweredBy% UUP dump API v%APIVersion%
GuiControl, Focus, BuildSearchQuery
Gui Show, w512 h404, %AppName%
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

    If(NewBuildIDs == "")
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
