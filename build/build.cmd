cd /d "%~dp0"
if NOT EXIST "bin\AutoHotkeyU32.exe" exit /b 1
rmdir /q /s temp 2>NUL
del ..\temp.7z 2>NUL
del ..\uupdownloader.7z 2>NUL
del ..\uupdownloader.exe 2>NUL

mkdir temp
mkdir temp\files
mkdir temp\files\src
xcopy /cherkyq ..\files temp\files\src\files\
xcopy /cherkyq ..\include temp\files\src\include\
copy ..\uupdownloader.ahk temp\files\src
copy "bin\AutoHotkeyU32.exe" temp\files\AutoHotkey.exe
copy src\run.cmd temp\uupdownloader.cmd

..\files\7za.exe -mx9 a ..\uupdownloader.7z .\temp\*

if NOT EXIST "bin\ResourceHacker.exe" exit /b 1
if NOT EXIST "bin\7zSD.sfx" exit /b 1

copy ..\sfxbootstrap.ahk temp\files\src
..\files\7za.exe -mx9 a ..\temp.7z .\temp\files\*
rmdir /q /s temp
mkdir temp
xcopy /cherkyq ..\res temp\
copy ..\files\icon.ico temp\icon.ico
cd temp
..\bin\ResourceHacker.exe -open resources.rc -save resources.res -action compile
cd ..
bin\ResourceHacker.exe -open bin\7zSD.sfx -save temp\7zSD.new -resource temp\resources.res -action addoverwrite
copy /b temp\7zSD.new + src\config.txt + ..\temp.7z ..\uupdownloader.exe
del ..\temp.7z
rmdir /q /s temp
