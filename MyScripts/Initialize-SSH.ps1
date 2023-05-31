[CmdletBinding()] param ()
$ErrorActionPreference = "Stop"

Write-Verbose "Configuring SSH"
if (-Not (Test-Path -Path $env:USERPROFILE/.ssh)) {
  ssh-keygen -t ed25519 -C "klas@mellbourn.net"
}
if ((Get-Service ssh-agent).StartType -ne "Automatic") {
  sudo Set-Service ssh-agent -StartupType Automatic
}
if ((Get-Service ssh-agent).Status -ne "Running") {
  Start-Service ssh-agent
}
