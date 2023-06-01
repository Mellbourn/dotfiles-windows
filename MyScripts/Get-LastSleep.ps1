[CmdletBinding()] param (
     [Parameter()]
     [ValidateRange("Positive")]
     [int]$Count = 5
)
$ErrorActionPreference = "Stop"

Get-EventLog -LogName System -Source Microsoft-Windows-Power-Troubleshooter
    | Where-Object { $_.InstanceId -eq 1 }
    | Select-Object -First $Count
    | Select-Object @{name = 'Time'; expression = { Get-Date $_.TimeGenerated } }, @{name = 'Message'; expression = { $_.Message.subString(0, $_.Message.IndexOf('Wake Source')) } }
    | Format-Table -AutoSize -Wrap
