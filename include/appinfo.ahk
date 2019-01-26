/*
This information file is used by UUP dump downloader script and by its build
script.
*/

AppNameOnly = UUP dump downloader
CompanyName = UUP dump authors
Version     = 1.2.0-beta.3
VersionExe  = 1,2,0,0

/*
Release type determines update check URL and if build metadata is shown in
version text displayed in application.

Possible values:
0 - Final release
1 - Testing release (alpha, beta, rc)
2 - Continous Integration (untested versions)
*/
ReleaseType = 2

;These values are there only, because they need to be used by build script
AppFileName = uupdownloader_%Version%
UserAgent   = %AppNameOnly%/%Version%
Copyright   = © %A_YYYY% %CompanyName%

;Version number without build metadata generation part
VersionNoMeta := StrSplit(Version, "+")
VersionNoMeta := VersionNoMeta.1

If(ReleaseType >= 2) {
    AppName = %AppNameOnly% v%Version%
} else {
    AppName = %AppNameOnly% v%VersionNoMeta%
}
