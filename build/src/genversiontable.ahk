WorkDir := A_WorkingDir
#Include %A_ScriptDir%\..\..\include\header.ahk
#Include %A_ScriptDir%\..\..\include\appinfo.ahk
SetWorkingDir, %WorkDir%

File1 = %1%
If File1 =
{
    msgbox file1 not specified
    ExitApp
}

File2 = %2%
If File2 =
{
    msgbox file2 not specified
    ExitApp
}

FileAppend,
(
1 VERSIONINFO
FILEVERSION %VersionExe%
PRODUCTVERSION %VersionExe%
FILEOS 0x40004
FILETYPE 0x1
{
    BLOCK "StringFileInfo"
    {
        BLOCK "040904b0"
        {
            VALUE "CompanyName", "%CompanyName%"
            VALUE "FileDescription", "%AppNameOnly%"
            VALUE "FileVersion", "%Version%"
            VALUE "InternalName", "%AppFileName%"
            VALUE "LegalCopyright", "%Copyright%"
            VALUE "OriginalFilename", "%AppFileName%.exe"
            VALUE "ProductName", "%AppNameOnly%"
            VALUE "ProductVersion", "%Version%"
        }
    }

    BLOCK "VarFileInfo"
    {
        VALUE "Translation", 0x0409 0x04B0
    }
}

), %File1%

FileAppend, set fileNames=%AppFileName%, %File2%
