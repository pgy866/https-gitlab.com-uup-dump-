﻿CheckVersion(Version, VersionCheckUrl) {
    Global AppName, text_UpdateAvailable, AppNameOnly

    LatestVersion := UrlGet(VersionCheckUrl, "GET")
    Temp := StrSplit(LatestVersion, "`n")
    LatestVersion := StrReplace(Temp[1], "`r")

    Version := StrSplit(Version, "+")
    Version := Version.1

    LatestVersionNoMeta := StrSplit(LatestVersion, "+")
    LatestVersionNoMeta := LatestVersionNoMeta.1

    if(Version != LatestVersionNoMeta)
    {
        GuiControl,, BottomInformationText, %text_UpdateAvailable% <a href="https://gitlab.com/uup-dump/downloader/tags/%LatestVersion%">%AppNameOnly% v%LatestVersion%</a>
        return 1
    }

    return 0
}

CreateWorkDir(Loc) {
    Global CurrentDrive, text_CreateDirFail, text_Error

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
    Global WorkDir, PhpPid

    SetTimer, MonitorPhp, Off
    Process, Close, %PhpPid%
    NewWorkDir := CreateWorkDir(Loc)

    FileCopyDir, %WorkDir%, %NewWorkDir%, 1
    SetWorkingDir %NewWorkDir%
    FileRemoveDir, %WorkDir%, 1

    WorkDir := NewWorkDir
    SetTimer, MonitorPhp, 100
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
    Global text_Error, text_CannotGetBuilds, text_NoSearchResults
    Global BuildNames, BuildNumbers, BuildArchs

    Response := RegExReplace(Response, "i)Cumulative ", "")
    Response := RegExReplace(Response, "i)Version Next", "Insider Preview")

    Search := RegExReplace(Search, "([\/\\+\*\?\[\^\]\$\(\)\{\}\=\!\<\>\|\:\-])", "\$1")
    Search := RegExReplace(Search, " ", ".*")

    BuildList =
    BuildIDs := []
    BuildNamesTemp := []
    BuildArchsTemp := []
    BuildNumbersTemp := []

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

        if ID !=
        {
            Index++

            BuildIDs[Index] := ID
            BuildNamesTemp[Index] := Name " " Arch
            BuildArchsTemp[Index] := Arch
            BuildNumbersTemp[Index] := Build
            BuildList .= Name " " Arch "|"
            if(Index = 1)
            {
                BuildList .= "|"
            }
        }
    }

    if (BuildList == "" && Search == "")
    {
        MsgBoxLock(16, text_Error, text_CannotGetBuilds)
        Gosub, KillApplication
    }

    if (BuildList == "")
    {
        MsgBoxLock(16, text_Error, text_NoSearchResults)
        Return
    }

    GuiControl, -Redraw, BuildSelect
    GuiControl, , BuildSelect, |
    GuiControl, , BuildSelect, %BuildList%
    GuiControl, +Redraw, BuildSelect

    BuildNames := BuildNamesTemp
    BuildArchs := BuildArchsTemp
    BuildNumbers := BuildNumbersTemp

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
            LangList .= Lang " / " Code "|"

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
        GuiControl,, BottomInformationText, %text_NoLanguages%
        MsgBoxLock(16, text_Error, text_NoLanguages)
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
        GuiControl,, BottomInformationText, %text_NoEditions%
        MsgBoxLock(16, text_Error, text_NoEditions)
        Return 0
    }

    EditionList = %text_AllEditions%||%EditionList%
    GuiControl, , EditionSelect, %EditionList%
    GuiControl, Enable, EditionSelect

    Return EditionCodes
}

GetFileInfoForUpdate(Update) {
    Global text_PleaseWait, text_Error, text_RetrievingFileinfo, text_NoFileinfo, text_RetrievingPacks
    Gui, +Disabled

    ProgressStyle = WM400 C00 ZH16 AM R0-10001

    IfNotExist src\fileinfo
    {
        FileCreateDir src\fileinfo
    }

    IfNotExist src\fileinfo\%Update%.json
    {
        Progress, 0 %ProgressStyle%, , %text_RetrievingFileinfo%, %text_PleaseWait%, Segoe UI
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
        ProgressStyle =
    }

    IfNotExist src\packs
    {
        FileCreateDir src\packs
    }

    IfNotExist src\packs\%Update%.json.gz
    {
        Progress, 5001 %ProgressStyle%, , %text_RetrievingPacks%, %text_PleaseWait%, Segoe UI
        Progress, 5000
        Response := UrlGet("https://gitlab.com/uup-dump/packs/raw/master/" Update ".json.gz", "HEAD")

        if(Response = 200)
        {
            Progress, 6001
            Progress, 6000
            URLDownloadToFile, https://gitlab.com/uup-dump/packs/raw/master/%Update%.json.gz, src\packs\%Update%.json.gz
        }

        Progress, 10001
        Progress, 10000
    }

    Gui, -Disabled
    Progress, off
}

GetFilesSize(SelectedBuild, SelectedLang, SelectedEdition) {
    Global PhpPort
    Output := UrlGet("http://127.0.0.1:" PhpPort "/getlist.php?id=" SelectedBuild "&pack=" SelectedLang "&edition=" SelectedEdition, "GET")

    FullSize := 0
    Loop, Parse, Output, `n
    {
        RegExMatch(A_LoopField, "SO)(.*)\|(.*)\|(.*)", Match)
        Size := Format("{:f}", Match.3)
        FullSize := FullSize + Size
    }

    Suffixes := ["K", "M", "G", "T", "P", "E", "Z", "Y"]
    Index := 0
    While(FullSize >= 1024 && Index < 8)
    {
        FullSize := FullSize / 1024
        Index += 1
    }

    Return Format("{:.2f}", FullSize) Suffixes[Index] "B"
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

CleanupForNewDownload() {
    Global WorkDir

    FileRemoveDir, %WorkDir%\UUPs, 1
    FileCreateDir, %WorkDir%\UUPs
    FileDelete, %WorkDir%\*.ISO
}

CheckADK() {
    if A_OSVersion in WIN_7,WIN_8,WIN_8.1
    {
        RegRead, KitsRootWow, HKLM\Software\Wow6432Node\Microsoft\Windows Kits\Installed Roots, KitsRoot10
        RegRead, KitsRoot, HKLM\Software\Microsoft\Windows Kits\Installed Roots, KitsRoot10

        if (KitsRoot == "" && KitsRootWow == "")
        {
            return 0
        } else {
            return 1
        }
    }
    return 1
}

GetCurrentSystemColor() {
    If(InStr(A_OSVersion, "10.0")) {
        RegRead, Color, HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Accent, AccentPalette
        return SubStr(Color, 25, 6)
    } else {
        return "1f59c3"
    }
}

DWMColorChangedEvent() {
    Global AppName

    Sleep, 33
    Color := GetCurrentSystemColor()

    Gui Font, s11 q5 c%Color%
    GuiControl, -Redraw, AppNameText
    GuiControl, Font, AppNameText
    GuiControl,, AppNameText, %AppName%
    GuiControl, +Redraw, AppNameText
    Gui Font, s9 q5
}

MsgBoxLock(Options, Title, Text) {
    Gui, +OwnDialogs +Disabled
    MsgBox, % Options, % Title, % Text
    Gui, -Disabled
}

UrlGet(URL, Method) {
    Global UserAgent
    WebRequest := ComObjCreate("MSXML2.XMLHTTP.6.0")
    WebRequest.Open(Method, URL, true)
    WebRequest.setRequestHeader("User-Agent", UserAgent)
    WebRequest.SetRequestHeader("If-Modified-Since", "Sat, 1 Jan 1970 00:00:00 GMT")
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
