[CmdletBinding()] param ()
$ErrorActionPreference = "Stop"

$DotfilesOutputDir = "$env:LOCALAPPDATA/Dotfiles"
if (-Not (Test-Path -Path $DotfilesOutputDir)) {
  New-Item -Type Directory -Path $DotfilesOutputDir/logs
}

$filename = (Get-DAte).ToString("yyyyMMddTHHmmss") + ".txt"
Start-Transcript -Append -IncludeInvocationHeader -Path $DotfilesOutputDir/logs/$filename

if (Get-Command "git.exe" -ErrorAction SilentlyContinue) {
  git -C $PSScriptRoot pull
}

if ((Get-ExecutionPolicy) -ne "RemoteSigned") {
  sudo powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force"
}

Write-Verbose "Make dotfiles always available on this device"
# Modules contain hidden xml files that will be skipped by default
attrib +p -h $PSScriptRoot\..\Modules\*.xml /s
attrib +p -h $PSScriptRoot\..\windows-terminal-icons\.git
attrib +p $PSScriptRoot\..\*.* /s

Install-WingetPackages @args

Install-BinPrograms @args

Install-Modules @args

# non installation configuration
if (-Not (Test-Path -Path $env:CodeDir/private)) {
  New-Item -Type Directory -Path $env:CodeDir/private
}

Initialize-SSH @args

Install-SymbolicLinks @args

Install-WSL @args

Write-Verbose "Miscellaneous configuration"

z -clean

Install-Fonts @args

Write-Verbose "Clean old files:"
Clear-OldFiles @args

Write-Verbose "Upgrading all powershell modules:"
Update-Module

Write-Verbose "Upgrading everything installed with winget:"
winget upgrade --all

Start-RecurrentUpdates @args -DotfilesOutputDir $DotfilesOutputDir

git -C $PSScriptRoot push

Stop-Transcript
