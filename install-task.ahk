; Register sing-tray on Task Scheduler
;

#Requires AutoHotkey v2.0
#SingleInstance Force

if !A_IsAdmin {
    Run '*RunAs "' A_AhkPath '" "' A_ScriptFullPath '"'
    ExitApp
}

TASK_NAME   := "sing-tray"
TARGET_SCRIPT := A_ScriptDir "\sing-tray.exe"

if !FileExist(TARGET_SCRIPT) {
    MsgBox "script not found：`n" TARGET_SCRIPT, "error", "Icon!"
    ExitApp
}

cmd := 'schtasks /Create'
    . ' /TN "' TASK_NAME '"'
    . ' /TR "\"' TARGET_SCRIPT '\""'
    . ' /SC ONLOGON'
    . ' /RU "' A_UserName '"'
    . ' /RL HIGHEST'
    . ' /IT'
    . ' /F'

ret := RunWait(A_ComSpec ' /C ' cmd,, "Hide")
if ret = 0 {
    MsgBox 'registered.'
} else {
    MsgBox 'failed.'
}
