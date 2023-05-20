[CmdletBinding()] param ()
$ErrorActionPreference = "Stop"
Push-Location $env:USERPROFILE


if ((Get-ExecutionPolicy) -ne "RemoteSigned") {
  gsudo -u $env:USERNAME { Set-ExecutionPolicy RemoteSigned }
}

$InstallListString = "

# foundational
Git.Git

# hardware related
# without DirectX Everquests throws Missing d3dx9_43.dll. Note, winget fails to detect this being installed
#Microsoft.DirectX
Intel.IntelDriverAndSupportAssistant, Nvidia.GeForceExperience, Kingston.SSDManager
# Windows Scanner
9WZDNCRFJ3PV

# security
Bitwarden.Bitwarden, schollz.croc, Twilio.Authy,  PrivateInternetAccess.PrivateInternetAccess

# misc
Google.Chrome.Beta, VideoLAN.VLC
# DominikReichl.KeePass

# developer
Microsoft.VisualStudioCode, Microsoft.PowerShell, gerardog.gsudo

# games
Valve.Steam

"
$InstallList = $InstallListString -split "`n"
foreach ($InstallLineString in $InstallList) {
  $InstallLine = $InstallLineString.Trim()
  if ($InstallLine -ne "" -and $InstallLine -notlike "#*") {
    $Install = $InstallLine.Split(",")
    foreach ($InstallItem in $Install) {
      $InstallItem = $InstallItem.Trim()
      if ($InstallItem -ne "") {
        Write-Verbose "`nInstalling '$InstallItem'"
        winget install -e --id $InstallItem
      }
    }
  }
}

$gitCryptPattern = "git-crypt-*-x86_64.exe"
if (-Not (Test-Path -Path bin/$gitCryptPattern)) {
  $installCommand = "& $PSScriptRoot\Install-LatestRelease.ps1 -repoName AGWA/git-crypt -assetPattern $gitCryptPattern"
  Invoke-Expression $installCommand
  sudo New-Item -ItemType SymbolicLink -Path bin/git-crypt.exe -Target bin/$gitCryptPattern
}

# non installation configuration

if (-Not (Test-Path -Path .gitconfig)) {
  Write-Verbose "`ngit configuration"
  sudo New-Item -ItemType SymbolicLink -Path .gitconfig -Target $PSScriptRoot/.gitconfig
}

Write-Verbose "`nConfiguring SSH"
if (-Not (Test-Path -Path .ssh)) {
  ssh-keygen -t ed25519 -C "klas@mellbourn.net"
}
if ((Get-Service ssh-agent).StartType -ne "Automatic") {
  sudo Set-Service ssh-agent -StartupType Automatic
}
if ((Get-Service ssh-agent).Status -ne "Running") {
  Start-Service ssh-agent
}
if (-Not (Test-Path -Path .ssh/config)) {
  sudo New-Item -ItemType SymbolicLink -Path .ssh/config -Target $PSScriptRoot/.ssh/config
  ssh-add .ssh/id_ed25519
}

if (wsl -l | Where-Object { $_.Replace("`0", "") -match '^Ubuntu' }) {
  Write-Verbose "`nWSL update"
  wsl --update
}
else {
  Write-Verbose "`nWSL install"
  wsl --install -d Ubuntu
}

Write-Verbose "`nMiscellaneous configuration"
# to get Remove-ItemSafely, i.e. deletion by moving to the trash
Install-Module -Name Recycle

# terminal settings - couldn't get this to work, terminal recreates settings when moved?
#$settingsPath = "$env:USERPROFILE\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
#if (-Not (Get-ChildItem $settingsPath).LinkType) {
#  Move-Item $settingsPath "$settingsPath.bak"
#  sudo New-Item -ItemType SymbolicLink -Path $settingsPath -Target $env:USERPROFILE/code/dotfiles-windows/terminal/settings.json
#}

Write-Verbose "`nInstalling fonts"
Push-Location code
if (-Not (Test-Path -Path nerd-fonts)) {
  git clone --filter=blob:none --depth=1 git@github.com:ryanoasis/nerd-fonts
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
    Write-Verbose "`nInstalling '$FontAlias'"
    .\install.ps1 $InstallFont
  }
}
Pop-Location
Pop-Location

Write-Verbose "`nUpgrading everything:"
winget upgrade --all

Pop-Location
