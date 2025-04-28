[CmdletBinding()] param ()
$ErrorActionPreference = "Stop"

if (-Not (Test-Path -Path $env:USERPROFILE/bin)) {
  New-Item -Type Directory -Path $env:USERPROFILE/bin
}

$gitCryptPattern = "git-crypt-*-x86_64.exe"
if (-Not (Test-Path -Path $env:USERPROFILE/bin/$gitCryptPattern)) {
  Write-Verbose "Installing git-crypt"
  Install-LatestRelease -repoName AGWA/git-crypt -assetPattern $gitCryptPattern
  sudo powershell -c "New-Item -ItemType SymbolicLink -Path $env:USERPROFILE/bin/git-crypt.exe -Target bin/$gitCryptPattern"
}
