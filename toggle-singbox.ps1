# Self-elevate the script if required
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Define the notification XML
$xml_started = @"
<toast>
    <visual>
        <binding template="ToastGeneric">
            <text>sing-box</text>
            <text>service started.</text>
        </binding>
    </visual>
</toast>
"@

$xml_stopped = @"
<toast>
    <visual>
        <binding template="ToastGeneric">
            <text>sing-box</text>
            <text>service stopped.</text>
        </binding>
    </visual>
</toast>
"@

$AppId = (Get-StartApps | Where-Object { $_.Name -eq "Windows PowerShell" }).AppID

function Show-Toast {
    param (
        [string]$xml
    )
    $xmlDoc = [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]::New()
    $xmlDoc.LoadXml($xml)
    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]::CreateToastNotifier($AppId).Show($xmlDoc)
}

$s = Get-Service -Name "sing-box"
if ($s.Status -eq 'Running') {
    Stop-Service $s
    Show-Toast $xml_stopped
} else {
    Start-Service $s
    Show-Toast $xml_started
}
