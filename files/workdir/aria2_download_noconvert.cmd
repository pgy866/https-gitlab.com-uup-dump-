@echo off
cd /d "%~dp0"
SETLOCAL ENABLEDELAYEDEXPANSION

set "aria2=files\aria2\aria2c.exe"
set "aria2Script=files\aria2_script.txt"
set "destDir=UUPs"

if NOT EXIST %aria2% goto :NO_ARIA2_ERROR
if NOT EXIST %aria2Script% goto :NO_FILE_ERROR

set "speedLimit=0"
if [%1] NEQ [] set "speedLimit=%1"

echo Starting download of files...
"%aria2%" -x16 -s16 -j5 -c -R --max-overall-download-limit=%speedLimit% -d"%destDir%" -i"%aria2Script%"
if %ERRORLEVEL% GTR 0 goto DOWNLOAD_ERROR

set esdsFound=0
for %%f in (UUPs\*.ESD) do set /a esdsFound=!esdsFound!+1
if %esdsFound% LSS 1 goto :DOWNLOAD_ERROR

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

:NO_FILE_ERROR
echo We couldn't find one of needed files for this script.
pause
exit /b 1
goto :EOF

:DOWNLOAD_ERROR
echo We have encountered an error while downloading files.
pause
exit /b 1
goto :EOF

:EOF
