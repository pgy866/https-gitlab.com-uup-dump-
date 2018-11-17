cd /d "%~dp0.."
"%ProgramFiles%\AutoHotkey\Compiler\Compile_AHK.exe" /nogui "%cd%\uupdownloader.ahk"

if NOT EXIST "C:\Program Files\AutoHotkey\AutoHotkeyU32.exe" goto :EOF
rmdir /q /s temp 2>NUL

cd build
mkdir temp
mkdir temp\files
mkdir temp\files\src
xcopy /cherkyq ..\files temp\files\src\files\
xcopy /cherkyq ..\lib temp\files\src\lib\
copy ..\uupdownloader.ahk temp\files\src
copy "C:\Program Files\AutoHotkey\AutoHotkeyU32.exe" temp\files\AutoHotkey.exe
copy src\run.cmd temp\uupdownloader.cmd

..\files\7za.exe -mx9 a ..\uupdownloader.7z .\temp\*
rmdir /q /s temp
