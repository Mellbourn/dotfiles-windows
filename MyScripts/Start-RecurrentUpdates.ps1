[CmdletBinding()] param ()
$ErrorActionPreference = "Stop"

Write-Verbose "Regularly run some programs that can offer updates:"

$commandLastRunFile = "$env:LOCALAPPDATA\RecurrentCommandLastRun.txt"
$currentDate = Get-Date

function Invoke-RecurrentCommands {
    Write-Verbose "Running programs..."
    ArmouryCrate.exe
    Start-Process -FilePath "$env:ProgramFiles\Kingston_SSD_Manager\KSM_Gen15.exe"
    Start-Process "$env:ProgramFiles\NVIDIA Corporation\NVIDIA GeForce Experience\NVIDIA GeForce Experience.exe"

    $currentDate | Set-Content $commandLastRunFile
}

if (Test-Path $commandLastRunFile) {
    $lastRunDateStr = Get-Content $commandLastRunFile | Out-String
    $lastRunDate = [DateTime]::Parse($lastRunDateStr)

    $daysSinceLastRun = ($currentDate - $lastRunDate).Days

    if ($daysSinceLastRun -ge 30) {
        Invoke-RecurrentCommands
        return
    }
    Write-Verbose "Programs were last run $daysSinceLastRun days ago. Waiting until 30 days have passed."
    return
}

Write-Verbose "Running for the first time"

Invoke-RecurrentCommands