<#
.SYNOPSIS

Download latest release of a binary from github project

.DESCRIPTION

Often needed

.NOTES


.EXAMPLE

.\Install-LatestRelease.ps1 -repoName PowerShell/PowerShell -assetPattern *-win-x64.msi

Isnstall latest release of PowerShell

.LINK
https://gist.github.com/maxkoshevoi/60d7b7910ad6ddcc6e1c9b656a8d0301#file-download-latest-release-ps1
#>

param(
    # name of repo in format "owner/repo", e.g. AGWA/git-crypt
    [Parameter()][string]$repoName,

    # pattern to match against asset name, e.g. *git-crypt-0.7.0-x86_64.exe
    [Parameter()][string]$assetPattern,

    # run this on remote branches instead of local
    [Parameter()][string]$extractDirectory = "$env:USERPROFILE\bin"
)

$releasesUri = "https://api.github.com/repos/$repoName/releases/latest"
$asset = (Invoke-WebRequest $releasesUri | ConvertFrom-Json).assets | Where-Object name -like $assetPattern
$downloadUri = $asset.browser_download_url

$extractPath = [System.IO.Path]::Combine($extractDirectory, $asset.name)
Invoke-WebRequest -Uri $downloadUri -Out $extractPath
