[CmdletBinding()] param ()
$ErrorActionPreference = "Stop"

Push-Location $env:USERPROFILE

if ((Get-ExecutionPolicy) -ne "RemoteSigned") {
  gsudo -u $env:USERNAME { Set-ExecutionPolicy RemoteSigned }
}

Write-Verbose "Make dotfiles always available on this device"
# Modules contain hidden xml files that will be skipped by default
attrib +p -h $PSScriptRoot\..\Modules\*.xml /s
attrib +p -h $PSScriptRoot\..\windows-terminal-icons\.git
attrib +p $PSScriptRoot\..\*.* /s

Install-WingetPackages @args

if (-Not (Test-Path -Path bin)) {
  New-Item -Type Directory -Path bin
}

$gitCryptPattern = "git-crypt-*-x86_64.exe"
if (-Not (Test-Path -Path bin/$gitCryptPattern)) {
  Write-Verbose "Installing git-crypt"
  Install-LatestRelease -repoName AGWA/git-crypt -assetPattern $gitCryptPattern
  sudo New-Item -ItemType SymbolicLink -Path bin/git-crypt.exe -Target bin/$gitCryptPattern
}

Install-Modules @args

# non installation configuration
if (-Not (Test-Path -Path $env:CodeDir/private)) {
  New-Item -Type Directory -Path $env:CodeDir/private
}

Write-Verbose "Configuring SSH"
if (-Not (Test-Path -Path .ssh)) {
  ssh-keygen -t ed25519 -C "klas@mellbourn.net"
}
if ((Get-Service ssh-agent).StartType -ne "Automatic") {
  sudo Set-Service ssh-agent -StartupType Automatic
}
if ((Get-Service ssh-agent).Status -ne "Running") {
  Start-Service ssh-agent
}

Write-Verbose "Symbolic links"
$LinkListString = "
# git config
.gitconfig

# SSH Config
.ssh\config

# winget settings
AppData\Local\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json

# Terminal settings
AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
"
$LinkList = $LinkListString -split "`n"
foreach ($LinkLineString in $LinkList) {
  $LinkLine = $LinkLineString.Trim()
  if ($LinkLine -ne "" -and $LinkLine -notlike "#*") {
    $LinkArray = $LinkLine.Split(",")
    foreach ($LinkItem in $LinkArray) {
      $Link = $LinkItem.Trim()
      if ($Link -ne "") {
        if (Test-Path -Path $Link) {
          if ((Get-ItemProperty -Path $Link -Name LinkType).LinkType -eq 'SymbolicLink') {
            continue
          }
          Write-Warning "`n'$Link exists but is not a link, creating backup"
          Copy-Item -Path $Link -Destination "$Link.$(Get-Date -UFormat "%Y%m%dT%H%M%S").bak"
        }
        Write-Verbose "Linking '$Link'"
        sudo New-Item -Force -ItemType SymbolicLink -Path $Link -Target $PSScriptRoot\..\HomeLinkTargets\$Link
      }
    }
  }
}

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

Write-Verbose "Installing fonts"
Push-Location $env:CodeDir/private
if (-Not (Test-Path -Path nerd-fonts)) {
  git clone --filter=blob:none --depth=1 --single-branch git@github.com:ryanoasis/nerd-fonts
}
Push-Location nerd-fonts
$InstallFontsString = "JetBrainsMono, CascadiaCode"
$FontsAliasString = "JetBrainsMono, CaskaydiaCove"
$InstallFontsList = $InstallFontsString -split ", "
$FontsAliasList = $FontsAliasString -split ", "
[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
for ($i = 0; $i -lt $InstallFontsList.Length; $i++) {
  $InstallFont = $InstallFontsList[$i]
  $FontAlias = $FontsAliasList[$i]
  if (-Not ((New-Object System.Drawing.Text.InstalledFontCollection).Families | Select-String $FontAlias)) {
    Write-Verbose "Installing '$FontAlias'"
    .\install.ps1 $InstallFont
  }
}
Pop-Location
Pop-Location

Write-Verbose "Clean old files:"
Clear-OldFiles @args

Start-RecurrentUpdates @args

Write-Verbose "Upgrading all powershell modules:"
Update-Module

Write-Verbose "Upgrading everything installed with winget:"
winget upgrade --all

Pop-Location
