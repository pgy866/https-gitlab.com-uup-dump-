pushd "%~dp0"
cd ..

call "build\clean.cmd"

files\7za.exe -mx9 a files\workdir.7z .\files\workdir\*
