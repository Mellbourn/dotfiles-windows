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

if (-Not (Test-Path -Path .ssh)) {
  ssh-keygen -t ed25519 -C "klas@mellbourn.net"
}

if (-Not (Test-Path -Path .gitconfig)) {
  sudo New-Item -ItemType SymbolicLink -Path .gitconfig -Target code/dotfiles-windows/.gitconfig
}

if ((Get-ExecutionPolicy) -ne "RemoteSigned") {
  gsudo -u $env:USERNAME { Set-ExecutionPolicy RemoteSigned }
}

# needed for ssh?
#Set-Service ssh-agent -StartupType Manual
#Set-Service -Name sshd -StartupType 'Automatic'

# needed for wsl?
#these are needed for WSL 2 https://success.docker.com/article/manually-enable-docker-for-windows-prerequisites
#Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
#Enable-WindowsOptionalFeature -Online -FeatureName Containers -All

# to get Remove-ItemSafely, i.e. deletion by moving to the trash
Install-Module -Name Recycle

# list potential updates
Write-Verbose "`nPotential upgrades:"
winget upgrade

Pop-Location
