[CmdletBinding()] param ()
$ErrorActionPreference = "Stop"

if ((Get-ExecutionPolicy) -ne "RemoteSigned") {
  gsudo -u $env:USERNAME { Set-ExecutionPolicy RemoteSigned }
}

Write-Verbose "Make dotfiles always available on this device"
# Modules contain hidden xml files that will be skipped by default
attrib +p -h $PSScriptRoot\..\Modules\*.xml /s
attrib +p -h $PSScriptRoot\..\windows-terminal-icons\.git
attrib +p $PSScriptRoot\..\*.* /s

Install-WingetPackages @args

if (-Not (Test-Path -Path $env:USERPROFILE/bin)) {
  New-Item -Type Directory -Path $env:USERPROFILE/bin
}

$gitCryptPattern = "git-crypt-*-x86_64.exe"
if (-Not (Test-Path -Path $env:USERPROFILE/bin/$gitCryptPattern)) {
  Write-Verbose "Installing git-crypt"
  Install-LatestRelease -repoName AGWA/git-crypt -assetPattern $gitCryptPattern
  sudo New-Item -ItemType SymbolicLink -Path $env:USERPROFILE/bin/git-crypt.exe -Target bin/$gitCryptPattern
}

Install-Modules @args

# non installation configuration
if (-Not (Test-Path -Path $env:CodeDir/private)) {
  New-Item -Type Directory -Path $env:CodeDir/private
}

Initialize-SSH @args

Install-SymbolicLinks @args

if (wsl -l | Where-Object { $_.Replace("`0", "") -match '^Ubuntu' }) {
  Write-Verbose "WSL update"
  wsl --update
}
else {
  Write-Verbose "WSL install"
  wsl --install -d Ubuntu
}

Write-Verbose "Miscellaneous configuration"

z -clean

Install-Fonts @args

Write-Verbose "Clean old files:"
Clear-OldFiles @args

Start-RecurrentUpdates @args

Write-Verbose "Upgrading all powershell modules:"
Update-Module

Write-Verbose "Upgrading everything installed with winget:"
winget upgrade --all
