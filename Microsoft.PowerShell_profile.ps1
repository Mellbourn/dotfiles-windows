# this script is used by PowerShell 7

$env:Path += ";$env:USERPROFILE\bin;$PSScriptRoot/MyScripts"

$env:CodeDir = "$env:USERPROFILE/code"

Set-Alias g git
function yb {
    Install-Dotfiles -Verbose
}

Import-Module z

oh-my-posh init pwsh | Invoke-Expression

Import-Module -Name Terminal-Icons

Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -BellStyle Audible -DingTone 100 -DingDuration 20
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
# this makes tab expansion work in git
Set-PsFzfOption -TabExpansion
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
