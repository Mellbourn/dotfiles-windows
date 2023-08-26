[CmdletBinding()] param ()
$ErrorActionPreference = "Stop"

Write-Verbose "Installing winget packages"
$InstallListString = "

# foundational
Git.Git

# hardware related
# without DirectX Everquests throws Missing d3dx9_43.dll. Note, winget fails to detect this being installed
#Microsoft.DirectX
Intel.IntelDriverAndSupportAssistant, Kingston.SSDManager, SteelSeries.GG
# display
Nvidia.GeForceExperience
# Windows HDR Calibration
9N7F2SM5D1LR
# Windows Scanner
9WZDNCRFJ3PV
# Dymo label printer
SanfordLP.DYMOConnect

# security
Bitwarden.Bitwarden, schollz.croc, Twilio.Authy,  PrivateInternetAccess.PrivateInternetAccess

# misc
Google.Chrome.Beta, VideoLAN.VLC
# DominikReichl.KeePass

# terminal
JanDeDobbeleer.OhMyPosh, junegunn.fzf, gerardog.gsudo, BurntSushi.ripgrep.MSVC, sharkdp.fd, jftuga.less, sharkdp.bat

# developer
Microsoft.VisualStudioCode, Microsoft.PowerShell

# games
Valve.Steam
# Discord.Discord kept starting up at startup

"
$wingetList = winget list | Out-String
$InstallList = $InstallListString -split "`n"
foreach ($InstallLineString in $InstallList) {
    $InstallLine = $InstallLineString.Trim()
    if ($InstallLine -ne "" -and $InstallLine -notlike "#*") {
        $InstallArray = $InstallLine.Split(",")
        foreach ($InstallWithSpace in $InstallArray) {
            $Install = $InstallWithSpace.Trim()
            if ($Install -ne "" -and (-Not ($wingetList -Match $Install))) {
                Write-Verbose "Installing '$Install'"
                winget install --accept-package-agreements --accept-source-agreements -e --id $Install
            }
        }
    }
}
