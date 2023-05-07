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
winget install -e --id Microsoft.VisualStudioCode
winget install -e --id Valve.Steam
winget install -e --id Microsoft.PowerShell
winget install -e --id schollz.croc

