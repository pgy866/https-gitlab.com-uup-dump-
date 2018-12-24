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
Translation["OldVersion"] := "You are running outdated version of UUP dump downloader. It is recommended to update to latest version."
Translation["YourVersion"] := "Your version"
Translation["LatestVersion"] := "Latest version"

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

ExtractTranslation(Locale) {
    If(Locale == "pl-PL")
    {
        FileInstall, files\lang\pl-PL.ini, %A_Temp%\UUPDUMP_translation.ini
        return
    }
    Else If(Locale == "nl-NL")
    {
        FileInstall, files\lang\nl-NL.ini, %A_Temp%\UUPDUMP_translation.ini
        return
    }
    Else If(Locale == "de-DE")
    {
        FileInstall, files\lang\de-DE.ini, %A_Temp%\UUPDUMP_translation.ini
        return
    }
    Else If(Locale == "ar-SA")
    {
        FileInstall, files\lang\ar-SA.ini, %A_Temp%\UUPDUMP_translation.ini
        return
    }
    Else If(Locale == "fr-FR")
    {
        FileInstall, files\lang\fr-FR.ini, %A_Temp%\UUPDUMP_translation.ini
        return
    }
    Else If(Locale == "ko-KR")
    {
        FileInstall, files\lang\ko-KR.ini, %A_Temp%\UUPDUMP_translation.ini
        return
    }
    Else If(Locale == "pt-PT")
    {
        FileInstall, files\lang\pt-PT.ini, %A_Temp%\UUPDUMP_translation.ini
        return
    }
    Else If(Locale == "pt-BR")
    {
        FileInstall, files\lang\pt-BR.ini, %A_Temp%\UUPDUMP_translation.ini
        return
    }
    Else If(Locale == "sv-SE")
    {
        FileInstall, files\lang\sv-SE.ini, %A_Temp%\UUPDUMP_translation.ini
        return
    }
    Else If(Locale == "es-ES")
    {
        FileInstall, files\lang\es-ES.ini, %A_Temp%\UUPDUMP_translation.ini
        return
    }
    Else If(Locale == "it-IT")
    {
        FileInstall, files\lang\it-IT.ini, %A_Temp%\UUPDUMP_translation.ini
        return
    }

    return
}

ExtractTranslation(Locale)

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
