cd /d "%~dp0"
::Archive creation
if NOT EXIST "bin\AutoHotkeyU32.exe" exit /b 1
rmdir /q /s temp 2>NUL
del temp.7z 2>NUL
del ..\uupdownloader*.7z 2>NUL
del ..\uupdownloader*.exe 2>NUL

mkdir temp
mkdir temp\files
mkdir temp\files\src
xcopy /cherkyq ..\files temp\files\src\files\
xcopy /cherkyq ..\include temp\files\src\include\
copy ..\uupdownloader.ahk temp\files\src
copy bin\AutoHotkeyU32.exe temp\files\AutoHotkey.exe
copy src\run.cmd temp\uupdownloader.cmd
bin\AutoHotkeyU32.exe src\touchdir.ahk temp

..\files\7za.exe -mx9 a ..\uupdownloader.7z .\temp\*

::Executable creation
if NOT EXIST "bin\ResourceHacker.exe" exit /b 1
if NOT EXIST "bin\7zSD.sfx" exit /b 1

copy ..\res\sfxbootstrap.ahk temp\files\src
bin\AutoHotkeyU32.exe src\touchdir.ahk temp
..\files\7za.exe -mx9 a temp.7z .\temp\files\*

rmdir /q /s temp
mkdir temp
copy /b bin\7zSD.sfx + src\config.txt + temp.7z temp\uupdownloader.exe
del temp.7z

xcopy /cherkyq ..\res temp\
copy ..\files\icon.ico temp\icon.ico
bin\AutoHotkeyU32.exe src\genversiontable.ahk temp\resources.rc temp\filenames.cmd

cd temp
..\bin\ResourceHacker.exe -open resources.rc -save resources.res -action compile
cd ..
bin\ResourceHacker.exe -open temp\uupdownloader.exe -save ..\uupdownloader.exe -resource temp\resources.res -action addoverwrite

::Final naming of files
call temp\filenames.cmd
ren ..\uupdownloader.exe "%fileNames%.exe"
ren ..\uupdownloader.7z "%fileNames%.7z"

::Cleanup
rmdir /q /s temp
