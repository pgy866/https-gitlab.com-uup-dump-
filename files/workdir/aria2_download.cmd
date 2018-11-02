@echo off
cd /d "%~dp0"

if NOT "%cd%"=="%cd: =%" (
    echo Current directory contains spaces in its path.
    echo Please move or rename the directory to one not containing spaces.
    echo.
    pause
    exit /b 1
    goto :EOF
)

NET SESSION >NUL 2>&1
IF %ERRORLEVEL% EQU 0 goto :START_PROCESS

echo =====================================================
echo This script needs to be executed as an administrator.
echo =====================================================
echo.
pause
exit /b 1
goto :EOF

:START_PROCESS
set "aria2=files\aria2c.exe"
set "a7z=files\7za.exe"
set "aria2Script=files\aria2_script.txt"
set "destDir=UUPs"

if NOT EXIST %aria2% goto :NO_ARIA2_ERROR
if NOT EXIST %a7z% goto :NO_FILE_ERROR

echo Starting download of files...
"%aria2%" -x16 -s16 -j5 -c -R -d"%destDir%" -i"%aria2Script%"
if %ERRORLEVEL% GTR 0 goto DOWNLOAD_ERROR

if EXIST convert-UUP.cmd goto :START_CONVERT
pause
goto :EOF

:START_CONVERT
call convert-UUP.cmd
goto :EOF

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
