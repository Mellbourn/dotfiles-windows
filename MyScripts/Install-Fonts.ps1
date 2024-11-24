[CmdletBinding()] param ()
$ErrorActionPreference = "Stop"

Write-Verbose "Installing fonts"
Push-Location $env:CodeDir/private
if (-Not (Test-Path -Path nerd-fonts)) {
  git clone --filter=blob:none --depth=1 --single-branch git@github.com:ryanoasis/nerd-fonts
}
Push-Location nerd-fonts
$InstallFontsString = "JetBrainsMono, CascadiaCode"
$FontsAliasString = "JetBrainsMono, CaskaydiaCove"
$InstallFontsList = $InstallFontsString -split ", "
$FontsAliasList = $FontsAliasString -split ", "
Add-Type -AssemblyName System.Drawing
for ($i = 0; $i -lt $InstallFontsList.Length; $i++) {
  $InstallFont = $InstallFontsList[$i]
  $FontAlias = $FontsAliasList[$i]
  if (-Not ((New-Object System.Drawing.Text.InstalledFontCollection).Families | Select-String $FontAlias)) {
    Write-Verbose "Installing '$FontAlias'"
    .\install.ps1 $InstallFont
  }
}
Pop-Location
Pop-Location

# Set the User-Agent header to avoid issues with GitHub API rate limiting
$headers = @{ 'User-Agent' = 'Mozilla/5.0' }

# Get the latest release information from Microsoft's Cascadia Code repository
$releaseInfo = Invoke-RestMethod -Uri "https://api.github.com/repos/microsoft/cascadia-code/releases/latest" -Headers $headers

# Find the CascadiaCode-<version>.zip asset
$asset = $releaseInfo.assets | Where-Object { $_.name -match '^CascadiaCode-.*\.zip$' }

if ($null -eq $asset) {
  Write-Error "CascadiaCode zip asset not found in the latest release."
  exit
}

$zipUrl = $asset.browser_download_url
$zipPath = "$env:TEMP\CascadiaCode.zip"
$extractPath = "$env:TEMP\CascadiaCodeFonts"

# Download the zip file
Write-Host "Downloading CascadiaCode zip file..."
Invoke-WebRequest -Uri $zipUrl -Headers $headers -OutFile $zipPath

# Clean up any existing extraction directory
If (Test-Path $extractPath) {
  Remove-Item $extractPath -Recurse -Force
}

Write-Host "Extracting fonts..."
Expand-Archive -LiteralPath $zipPath -DestinationPath $extractPath

# Get the list of font files (ttf and otf)
$fontFiles = Get-ChildItem -Path $extractPath -Include *.ttf, *.otf -Recurse

Write-Host "Installing fonts..."
$shellApp = New-Object -ComObject Shell.Application
$fontsFolder = $shellApp.Namespace(0x14)  # Special folder for Fonts

foreach ($fontFile in $fontFiles) {
  Write-Host "Installing $($fontFile.Name)..."
  $fontsFolder.CopyHere($fontFile.FullName)
}

Write-Host "Fonts installed successfully."

# Clean up temporary files
Remove-Item $zipPath -Force
Remove-Item $extractPath -Recurse -Force
