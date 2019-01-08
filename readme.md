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
This application is known to be detected by many AntiVirus engines as
malicious. This may be because of using AutoHotkey or other reasons known
only by these vendors.

If your AntiVirus solution detects this application executable as a virus then
try downloading Archive version of application which is simply a distribution
of AutoHotkey with all needed files to run UUP dump downloader.

### Downloads
Downloads of this application can be found in GitLab tags section.
https://gitlab.com/uup-dump/downloader/tags

### Building executable file
To build this project into single executable you need the following:
  - [AutoHotkey](https://www.autohotkey.com/download/) installed in `C:\Program Files\AutoHotkey`
  - [Latest unofficial release of Compile_AHK](https://github.com/mercury233/compile-ahk/releases)
    installed

To start build process run `build\build.cmd`.

### What is going on with version numbers of executable?
Because of limitations of version number string in executable files the version
numbers are like the folllowing:

major.minor.patch.rel_type

major.minor.patch is typical semantic versioning.

rel_type uses these rules:
  - rel_type < 1000 means that this is alpha release
  - rel_type > 1000 and < 2000 means that this is beta release
  - rel_type > 2000 and < 3000 means that this is release candidate
  - rel_type > 3000 and < 5000 are reserved for later use
  - rel_type = 5000 means that this is final release.

### Projects used in this project
  - aria2 (https://aria2.github.io/)
  - PHP (http://php.net/)
  - UUP to ISO conversion script by abbodi1406
