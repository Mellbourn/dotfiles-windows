[CmdletBinding()] param ()
$ErrorActionPreference = "Stop"

$commandLastRunFile = "$env:LOCALAPPDATA\RecurrentCommandLastRun.txt"

$currentDate = Get-Date

function Invoke-RecurrentCommands {
    Write-Verbose "Running command..."
    ArmouryCrate.exe
    Start-Process -FilePath "$env:ProgramFiles\Kingston_SSD_Manager\KSM_Gen15.exe"

    $currentDate | Set-Content $commandLastRunFile
}

if (Test-Path $commandLastRunFile) {
    $lastRunDateStr = Get-Content $commandLastRunFile | Out-String
    $lastRunDate = [DateTime]::Parse($lastRunDateStr)

    $daysSinceLastRun = ($currentDate - $lastRunDate).Days

    if ($daysSinceLastRun -ge 30) {
        Invoke-RecurrentCommands
    }
    else {
        Write-Verbose "Command was last run $daysSinceLastRun days ago. Waiting until 30 days have passed."
    }
    return
}

Write-Verbose "Running command for the first time..."

Invoke-RecurrentCommands
