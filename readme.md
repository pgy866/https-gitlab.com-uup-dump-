UUP dump downloader
-------------------

### Description
A project aiming to create foolproof application allowing easy creation of
Windows installation images from Unified Update Platform.

This application uses UUP dump API project as it's backend to generate
required links. Communication with API is done by using internal PHP webserver.

If you want to browse temporary working directory created by this application
press `ALT + D` while in main window.

### AntiVirus false positives
This application may be detected by some AntiVirus engines due to usage of
AutoHotkey. Reasons of this are only known by AntiVirus vendors.

If your AntiVirus solution detects this application executable as a virus then
try downloading Archive version of application which is simply a distribution
of AutoHotkey with all needed files to run UUP dump downloader.

### Downloads
Downloads of this application can be found in GitLab tags section.
https://gitlab.com/uup-dump/downloader/tags

### Unstable / testing versions
Untested versions that are currently in development can be downloaded from
[AppVeyor](https://ci.appveyor.com/project/whatever127/downloader/build/artifacts)

### Building executable file
To build this project into single executable you need the following in
`build\bin` directory:

  - [AutoHotkeyU32.exe](https://www.autohotkey.com/download/) from AutoHotkey
    zip file
  - [ResourceHacker.exe](http://www.angusj.com/resourcehacker/) from
    ResourceHacker zip file
  - [7zSD.sfx](https://www.7-zip.org/download.html) from 7-Zip LZMA SDK
    (the file can be found in `bin` directory of sdk archive)

To start build process run `build\build.cmd`.

### Projects used in this project
  - aria2 (https://aria2.github.io/)
  - PHP (http://php.net/)
  - UUP to ISO conversion script by abbodi1406
