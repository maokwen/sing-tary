; sing-box Service Tray Manager
;
;@Ahk2Exe-AddResource tray_stopped.ico
;@Ahk2Exe-AddResource tray_started.ico
;@Ahk2Exe-AddResource tray_unknown.ico

#Requires AutoHotkey v2.0
#SingleInstance Force


; --- admin ---
;

if not A_IsAdmin {
    Run '*RunAs "' A_AhkPath '" "' A_ScriptFullPath '"'
    ExitApp
}


; --- config ---
;

SERVICE_NAME := "sing-box"


; --- tray ---
;

A_TrayMenu.Delete()
A_TrayMenu.Add("Start sing-box", MenuStartService)
A_TrayMenu.Add("Stop sing-box", MenuStopService)
A_TrayMenu.Add()
A_TrayMenu.Add("Reload", MenuReload)
A_TrayMenu.Add("Exit", MenuExit)

UpdateTrayStatus()
SetTimer(UpdateTrayStatus, 5000)


; --- menu ---
;

MenuStartService(*) {
    StartService()
    Sleep 1500
    UpdateTrayStatus()
}

MenuStopService(*) {
    StopService()
    Sleep 1500
    UpdateTrayStatus()
}

MenuReload(*) {
    Reload
}

MenuExit(*) {
    ExitApp
}

; --- utils ---
;

GetServiceStatus() {
    global SERVICE_NAME
    result := ""
    try {
        WMI := ComObjGet("winmgmts:")
        query := "SELECT * FROM Win32_Service WHERE Name = '" SERVICE_NAME "'"
        WMI.ExecQuery(query)._NewEnum()(&service)
        result := service.State
    } catch {
        result := "Unknown"
    }
    return result
}

StartService() {
    global SERVICE_NAME
    global WMI := ComObjGet("winmgmts:")
    global query := "SELECT * FROM Win32_Service WHERE Name = '" SERVICE_NAME "'"
    WMI.ExecQuery(query)._NewEnum()(&service)
    if service.State == "Running" {
        TrayTip "Service already running.", "sing-box"
        return
    }
    service.StartService()
}

StopService() {
    global SERVICE_NAME
    global WMI := ComObjGet("winmgmts:")
    global query := "SELECT * FROM Win32_Service WHERE Name = '" SERVICE_NAME "'"
    WMI.ExecQuery(query)._NewEnum()(&service)
    if service.State == "Stopped" {
        TrayTip "Service already stopped.", "sing-box"
        return
    }
    service.StopService
}

UpdateTrayStatus() {
    status := GetServiceStatus()
    if status = "Stopped" {
        A_IconTip := "sing-box — Stopped"
        TraySetIcon 'tray_stopped.ico'
        A_TrayMenu.Enable("start sing-box")
        A_TrayMenu.Disable("stop sing-box")
    } else if status = "Running" {
        A_IconTip := "sing-box — Runnning"
        TraySetIcon 'tray_started.ico'
        A_TrayMenu.Enable("stop sing-box")
        A_TrayMenu.Disable("start sing-box")
    } else {
        A_IconTip := "sing-box — Unknown"
        TraySetIcon 'tray_unknown.ico'
        A_TrayMenu.Enable("start sing-box")
        A_TrayMenu.Enable("stop sing-box")
    }
}
