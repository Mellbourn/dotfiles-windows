[CmdletBinding()] param ()
$ErrorActionPreference = "Stop"

Write-Verbose "Symbolic links"
$LinkListString = "
# git config
.gitconfig
.gitconfig.aliases

# SSH Config
.ssh\config

# winget settings
AppData\Local\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json

# Terminal settings
AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json

# lsd settings
AppData\Roaming\lsd\config.yaml
"
$LinkList = $LinkListString -split "`n"
foreach ($LinkLineString in $LinkList) {
    $LinkLine = $LinkLineString.Trim()
    if ($LinkLine -ne "" -and $LinkLine -notlike "#*") {
        $LinkArray = $LinkLine.Split(",")
        foreach ($LinkItem in $LinkArray) {
            $LinkBase = $LinkItem.Trim()
            if ($LinkBase -ne "") {
                $Link = Join-Path -Path $env:USERPROFILE -ChildPath $LinkBase
                if (Test-Path -Path $Link) {
                    if ((Get-ItemProperty -Path $Link -Name LinkType).LinkType -eq 'SymbolicLink') {
                        continue
                    }
                    Write-Warning "`n'$Link exists but is not a link, creating backup"
                    Copy-Item -Path $Link -Destination "$Link.$(Get-Date -UFormat "%Y%m%dT%H%M%S").bak"
                }
                Write-Verbose "Linking '$Link'"
                sudo powershell -c "New-Item -Force -ItemType SymbolicLink -Path $Link -Target $PSScriptRoot\..\HomeLinkTargets\$LinkBase"
            }
        }
    }
}
