# Startup script is used by PowerShell 7

################################# Environment variables #################################
$env:Path += ";$env:USERPROFILE\bin;$PSScriptRoot/MyScripts"
# these are installed by winget, but incorrectly added to path
$env:Path += ";" + (Resolve-Path $env:LOCALAPPDATA/Microsoft\WinGet\Packages\BurntSushi.ripgrep.MSVC_Microsoft.Winget.Source_*\ripgrep-*-x86_64-pc-windows-msvc)
$env:Path += ";" + (Resolve-Path $env:LOCALAPPDATA/Microsoft\WinGet\Packages\sharkdp.bat_Microsoft.Winget.Source_*\bat-v*-x86_64-pc-windows-msvc)
$env:Path += ";" + (Resolve-Path $env:LOCALAPPDATA/Microsoft\WinGet\Packages\sharkdp.fd_Microsoft.Winget.Source_*\fd-v*-x86_64-pc-windows-msvc)

$env:CodeDir = "$env:USERPROFILE/code"

$env:BAT_CONFIG_PATH = "$PSScriptRoot/.config/bat/config"
$env:LESS = " --LONG-PROMPT --RAW-CONTROL-CHARS --ignore-case --HILITE-UNREAD --status-column --quiet --no-histdups --save-marks --quit-if-one-screen --incsearch --use-color"
$env:FZF_DEFAULT_OPTS = "--ansi --select-1 --height ~40% --reverse --tiebreak=begin --bind end:preview-down,home:preview-up,ctrl-a:select-all+accept --color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4"

################################# Aliases and simple functions #################################
Set-Alias g git
Set-Alias trash Remove-ItemSafely
function .. { Set-Location .. }
function yb {
    Install-Dotfiles -Verbose
}
function less {
    bat --pager "less -+E $env:LESS" $args
}

################################# module imports #################################
Import-Module z

oh-my-posh init pwsh --config "$PSScriptRoot/MyConfig/oh-my-posh/mytheme.omp.json" | Invoke-Expression

# I love the icons like in lsd, but this is really slow, about 300ms
Import-Module -Name Terminal-Icons

################################# PSReadLine #################################
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -BellStyle Audible -DingTone 100 -DingDuration 20
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r' -EnableAliasFuzzyKillProcess -GitKeyBindings -EnableAliasFuzzyEdit -EnableAliasFuzzyGitStatus
# this makes tab expansion work in git
Set-PsFzfOption -TabExpansion
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }

Initialize-PSReadLine.ps1
