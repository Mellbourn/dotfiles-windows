[CmdletBinding()] param ()
$ErrorActionPreference = "Stop"

if (wsl -l | Where-Object { $_.Replace("`0", "") -match '^Ubuntu' }) {
  Write-Verbose "WSL update"
  wsl --update
}
else {
  Write-Verbose "WSL install"
  wsl --install --no-launch --distribution Ubuntu
}
