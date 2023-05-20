# this script is used by PowerShell 7

# should I set the path to $PSScriptRoot/Scripts instead?
$env:Path += ";$env:USERPROFILE\bin;$PSScriptRoot"

Set-Alias g git
function yb {
    . "$PSScriptRoot\Install-Dotfiles.ps1" -Verbose
}

Import-Module z

oh-my-posh init pwsh | Invoke-Expression

Import-Module -Name Terminal-Icons

Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -PredictionViewStyle ListView
