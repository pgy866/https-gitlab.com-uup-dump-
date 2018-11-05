@echo off
cd /d "%~dp0"

set "aria2=files\aria2c.exe"
set "aria2Script=files\aria2_script.txt"
set "destDir=UUPs"

if NOT EXIST %aria2% goto :NO_ARIA2_ERROR

echo Starting download of files...
"%aria2%" -x16 -s16 -j5 -c -R -d"%destDir%" -i"%aria2Script%"
if %ERRORLEVEL% GTR 0 goto DOWNLOAD_ERROR

erase /q /s "%aria2Script%" >NUL 2>&1
pause
goto EOF

:NO_ARIA2_ERROR
echo We couldn't find %aria2% in current directory.
echo.
echo You can download aria2 from:
echo https://aria2.github.io/
echo.
pause
exit /b 1
goto :EOF

:DOWNLOAD_ERROR
echo We have encountered an error while downloading files.
pause
exit /b 1
goto :EOF

:EOF