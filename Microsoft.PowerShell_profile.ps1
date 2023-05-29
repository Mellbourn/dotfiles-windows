# this script is used by PowerShell 7

$env:Path += ";$env:USERPROFILE\bin;$PSScriptRoot/MyScripts"

# ripgrep is installed by winget, but incorrectly added to path
$env:Path += ";" + (Resolve-Path $env:LOCALAPPDATA/Microsoft\WinGet\Packages\BurntSushi.ripgrep.MSVC_Microsoft.Winget.Source_*\ripgrep-*-x86_64-pc-windows-msvc)
$env:Path += ";" + (Resolve-Path $env:LOCALAPPDATA/Microsoft\WinGet\Packages\sharkdp.bat_Microsoft.Winget.Source_*\bat-v*-x86_64-pc-windows-msvc)
$env:Path += ";" + (Resolve-Path $env:LOCALAPPDATA/Microsoft\WinGet\Packages\sharkdp.fd_Microsoft.Winget.Source_*\fd-v*-x86_64-pc-windows-msvc)


$env:CodeDir = "$env:USERPROFILE/code"

Set-Alias g git
function Get-LastSleep($Count = 5) {
    Get-EventLog -LogName System -Source Microsoft-Windows-Power-Troubleshooter | Where-Object { $_.InstanceId -eq 1 } | Select-Object -First $Count | Select-Object @{name = 'Time'; expression = { Get-Date $_.TimeGenerated } }, @{name = 'Message'; expression = { $_.Message.subString(0, $_.Message.IndexOf('Wake Source')) } } | Format-Table -AutoSize -Wrap
}
function yb {
    Install-Dotfiles -Verbose
}

Import-Module z

oh-my-posh init pwsh --config "$PSScriptRoot/MyConfig/oh-my-posh/mytheme.omp.json" | Invoke-Expression

# I love the icons like in lsd, but this is really slow, about 300ms
Import-Module -Name Terminal-Icons

Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -BellStyle Audible -DingTone 100 -DingDuration 20
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r' -EnableAliasFuzzyKillProcess -GitKeyBindings -EnableAliasFuzzyEdit -EnableAliasFuzzyGitStatus
# this makes tab expansion work in git
Set-PsFzfOption -TabExpansion
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }

Initialize-PSReadLine.ps1

$env:BAT_CONFIG_PATH = "$PSScriptRoot/.config/bat/config"
$env:LESS = " --LONG-PROMPT --RAW-CONTROL-CHARS --ignore-case --HILITE-UNREAD --status-column --quiet --no-histdups --save-marks --quit-if-one-screen --incsearch --use-color"
$env:FZF_DEFAULT_OPTS = "--ansi --select-1 --height ~40% --reverse --tiebreak=begin --bind end:preview-down,home:preview-up,ctrl-a:select-all+accept --color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4"

function less {
    bat --pager "less -+E $env:LESS" $args
}
