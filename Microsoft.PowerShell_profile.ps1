# this script is used by PowerShell 7

$env:Path += ";$env:USERPROFILE\bin"

Set-Alias g git
function yb {
    . "$PSScriptRoot\Install-Dotfiles.ps1" -Verbose
}

Import-Module z

oh-my-posh init pwsh | Invoke-Expression

Import-Module -Name Terminal-Icons
