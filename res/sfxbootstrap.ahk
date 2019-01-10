#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

SetBatchLines -1
#NoTrayIcon
#SingleInstance off

ScriptPid := GetCurrentProcess()
ParentPid := GetParentProcess(ScriptPid)
ParentExe := GetModuleFileNameEx(ParentPid)

; https://www.autohotkey.com/boards/viewtopic.php?p=9115#p9115
GetParentProcess(PID)
{
  static function := DllCall("GetProcAddress", "ptr", DllCall("GetModuleHandle", "str", "kernel32.dll", "ptr"), "astr", "Process32Next" (A_IsUnicode ? "W" : ""), "ptr")
  if !(h := DllCall("CreateToolhelp32Snapshot", "uint", 2, "uint", 0))
    return
  VarSetCapacity(pEntry, sz := (A_PtrSize = 8 ? 48 : 36)+(A_IsUnicode ? 520 : 260))
  Numput(sz, pEntry, 0, "uint")
  DllCall("Process32First" (A_IsUnicode ? "W" : ""), "ptr", h, "ptr", &pEntry)
  loop
  {
    if (pid = NumGet(pEntry, 8, "uint") || !DllCall(function, "ptr", h, "ptr", &pEntry))
      break
  }
  DllCall("CloseHandle", "ptr", h)
  return Numget(pEntry, 16+2*A_PtrSize, "uint")
}

GetProcessName(PID)
{
  static function := DllCall("GetProcAddress", "ptr", DllCall("GetModuleHandle", "str", "kernel32.dll", "ptr"), "astr", "Process32Next" (A_IsUnicode ? "W" : ""), "ptr")
  if !(h := DllCall("CreateToolhelp32Snapshot", "uint", 2, "uint", 0))
    return
  VarSetCapacity(pEntry, sz := (A_PtrSize = 8 ? 48 : 36)+260*(A_IsUnicode ? 2 : 1))
  Numput(sz, pEntry, 0, "uint")
  DllCall("Process32First" (A_IsUnicode ? "W" : ""), "ptr", h, "ptr", &pEntry)
  loop
  {
    if (pid = NumGet(pEntry, 8, "uint") || !DllCall(function, "ptr", h, "ptr", &pEntry))
      break
  }
  DllCall("CloseHandle", "ptr", h)
  return StrGet(&pEntry+28+2*A_PtrSize, A_IsUnicode ? "utf-16" : "utf-8")
}

GetCurrentProcess()
{
  return DllCall("GetCurrentProcessId")
}

; https://autohotkey.com/board/topic/17054-parent-processid-processname-processthreadcount/
GetModuleFileNameEx(ProcessID)  ; modified version of shimanov's function
{
  if A_OSVersion in WIN_95, WIN_98, WIN_ME
    Return GetProcessName(ProcessID)

  ; #define PROCESS_VM_READ           (0x0010)
  ; #define PROCESS_QUERY_INFORMATION (0x0400)
  hProcess := DllCall( "OpenProcess", "UInt", 0x10|0x400, "Int", False, "UInt", ProcessID)
  if (ErrorLevel or hProcess = 0)
    Return
  FileNameSize := 260 * (A_IsUnicode ? 2 : 1)
  VarSetCapacity(ModuleFileName, FileNameSize, 0)
  CallResult := DllCall("Psapi.dll\GetModuleFileNameEx", "Ptr", hProcess, "Ptr", 0, "Str", ModuleFileName, "UInt", FileNameSize)
  DllCall("CloseHandle", "Ptr", hProcess)
  Return ModuleFileName
}

#Include %A_ScriptDir%\uupdownloader.ahk
