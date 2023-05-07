Push-Location $USERPROFILE
# foundational
winget install -e --id Git.Git

# hardware related
# without this Everquests throws Missing d3dx9_43.dll. Note, winget fails to detect this being installed
#winget install -e --id Microsoft.DirectX
winget install -e --id Intel.IntelDriverAndSupportAssistant
winget install -e --id Nvidia.GeForceExperience

#misc
winget install -e --id Google.Chrome
winget install -e --id Bitwarden.Bitwarden
# winget install -e --id DominikReichl.KeePass
winget install -e --id schollz.croc

# developer
winget install -e --id Microsoft.VisualStudioCode
winget install -e --id Microsoft.PowerShell
winget install -e --id gerardog.gsudo

# games
winget install -e --id Valve.Steam

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


Pop-Location
