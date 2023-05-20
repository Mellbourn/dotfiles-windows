# this script is used by PowerShell 7

$env:Path += ";$env:USERPROFILE\bin;$PSScriptRoot/MyScripts"

Set-Alias g git
function yb {
    Install-Dotfiles -Verbose
}

Import-Module z

oh-my-posh init pwsh | Invoke-Expression

Import-Module -Name Terminal-Icons

Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -PredictionViewStyle ListView
