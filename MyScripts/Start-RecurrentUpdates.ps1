[CmdletBinding()] param (
    [Parameter()]
    [ValidateRange("NonNegative")]
    [int]$MaxAge = 10,

    [Parameter()]
    [switch]$Force,

    [Parameter()]
    [string]$DotfilesOutputDir = "$env:LOCALAPPDATA/Dotfiles"
)
$ErrorActionPreference = "Stop"
$Verbose = $PSBoundParameters['Verbose'] -or $VerbosePreference -eq 'Continue'

Write-Verbose "Regularly run some programs that can offer updates:"

$commandLastRunFile = "$DotfilesOutputDir\RecurrentCommandLastRun.txt"
$currentDate = Get-Date

function Invoke-RecurrentCommands {
    Write-Verbose "Running programs..."
    ArmouryCrate.exe
    Start-Process -FilePath "$env:ProgramFiles\Kingston_SSD_Manager\KSM_Gen15.exe"
    Start-Process "$env:ProgramFiles\NVIDIA Corporation\NVIDIA app\CEF\NVIDIA app.exe"

    Write-Verbose "Installing windows updates:"
    if ($Verbose) {
        sudo powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& {Import-Module '$env:USERPROFILE\OneDrive\Dokument\PowerShell\Modules\PSWindowsUpdate'; Get-WindowsUpdate -AcceptAll -Install -AutoReboot -Verbose}"
    }
    else {
        sudo powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& {Import-Module '$env:USERPROFILE\OneDrive\Dokument\PowerShell\Modules\PSWindowsUpdate'; Get-WindowsUpdate -AcceptAll -Install -AutoReboot}"
    }
    Start-Process "ms-settings:windowsupdate-optionalupdates"

    $currentDate | Set-Content $commandLastRunFile
}

if ($Force) {
    Invoke-RecurrentCommands
    return
}

if (Test-Path $commandLastRunFile) {
    $lastRunDateStr = Get-Content $commandLastRunFile | Out-String
    $lastRunDate = [DateTime]::Parse($lastRunDateStr)

    $daysSinceLastRun = ($currentDate - $lastRunDate).Days

    if ($daysSinceLastRun -ge $MaxAge) {
        Invoke-RecurrentCommands
        return
    }
    Write-Verbose "Programs were last run $daysSinceLastRun days ago. Waiting until $MaxAge days have passed."
    return
}

Write-Verbose "Running for the first time"

Invoke-RecurrentCommands
