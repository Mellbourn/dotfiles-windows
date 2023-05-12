[CmdletBinding()] param ()
$ErrorActionPreference = "Stop"
Push-Location $env:USERPROFILE

$InstallListString = "

# foundational
Git.Git

# hardware related
# without DirectX Everquests throws Missing d3dx9_43.dll. Note, winget fails to detect this being installed
#Microsoft.DirectX
Intel.IntelDriverAndSupportAssistant, Nvidia.GeForceExperience

# misc
Google.Chrome, Bitwarden.Bitwarden, schollz.croc, Twilio.Authy, VideoLAN.VLC
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

# non installation configuration

# ssh
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
  sudo New-Item -ItemType SymbolicLink -Path .ssh/config -Target $env:USERPROFILE/code/dotfiles-windows/.ssh/config
  ssh-add .ssh/id_ed25519
}

if (-Not (Test-Path -Path .gitconfig)) {
  sudo New-Item -ItemType SymbolicLink -Path .gitconfig -Target code/dotfiles-windows/.gitconfig
}

if ((Get-ExecutionPolicy) -ne "RemoteSigned") {
  gsudo -u $env:USERNAME { Set-ExecutionPolicy RemoteSigned }
}

# needed for wsl?
#these are needed for WSL 2 https://success.docker.com/article/manually-enable-docker-for-windows-prerequisites
#Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
#Enable-WindowsOptionalFeature -Online -FeatureName Containers -All

# to get Remove-ItemSafely, i.e. deletion by moving to the trash
Install-Module -Name Recycle

# Fonts
Write-Verbose "`nInstalling fonts"
Push-Location code
if (-Not (Test-Path -Path nerd-fonts)) {
  git clone --filter=blob:none git@github.com:ryanoasis/nerd-fonts
}
Push-Location nerd-fonts
git pull
$InstallFontsString = "JetBrainsMono,CascadiaCode"
$InstallFontsList = $InstallFontsString -split ","
[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
foreach ($InstallFontsString in $InstallFontsList) {
  $InstallFont = $InstallFontsString.Trim()
  if ($InstallFont -ne "") {
    if (-Not ((New-Object System.Drawing.Text.InstalledFontCollection).Families | Select-String $InstallFont)) {
      Write-Verbose "`nInstalling '$InstallFont'"
      .\install.ps1 $InstallFont
    }
  }
}
Pop-Location
Pop-Location

# list potential updates
Write-Verbose "`nPotential upgrades:"
winget upgrade

Pop-Location
