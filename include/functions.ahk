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
