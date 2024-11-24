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

# Load the System.Drawing assembly to work with fonts
Add-Type -AssemblyName System.Drawing

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
Write-Verbose "Downloading CascadiaCode zip file..."
Invoke-WebRequest -Uri $zipUrl -Headers $headers -OutFile $zipPath

# Clean up any existing extraction directory
If (Test-Path $extractPath) {
  Remove-Item $extractPath -Recurse -Force
}

Write-Verbose "Extracting fonts..."
Expand-Archive -LiteralPath $zipPath -DestinationPath $extractPath

# Get the list of font files (only OTF)
$fontFiles = Get-ChildItem -Path $extractPath -Include *.otf -Recurse

# Function to retrieve installed fonts from a registry path
function Get-InstalledFontFilesFromRegistry {
  param (
    [string]$registryPath
  )
  $installedFonts = @{}
  try {
    $fontRegistryEntries = Get-ItemProperty -Path $registryPath
    foreach ($prop in $fontRegistryEntries.PSObject.Properties) {
      $fontFileName = [System.IO.Path]::GetFileName($prop.Value).ToLower()
      if (-not [string]::IsNullOrEmpty($fontFileName)) {
        $installedFonts[$fontFileName] = $true
      }
    }
  }
  catch {
    Write-Verbose "Registry path $registryPath not found or inaccessible."
  }
  return $installedFonts
}

Write-Verbose "Retrieving installed fonts from registry..."

# Retrieve installed fonts from HKLM and HKCU
$installedFontsHKLM = Get-InstalledFontFilesFromRegistry -registryPath "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
$installedFontsHKCU = Get-InstalledFontFilesFromRegistry -registryPath "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"

# Combine the installed fonts into one hashtable
$installedFontFiles = @{}
foreach ($fontFile in @($installedFontsHKLM.Keys + $installedFontsHKCU.Keys)) {
  $installedFontFiles[$fontFile] = $true
}

Write-Verbose "Total installed fonts found: $($installedFontFiles.Count)"

Write-Verbose "Installing fonts..."
$shellApp = New-Object -ComObject Shell.Application
$fontsFolder = $shellApp.Namespace(0x14)  # Special folder for Fonts

# Suppress confirmation prompts and UI
$copyHereFlags = 0x14  # FOF_NOCONFIRMATION (0x10) + FOF_NOERRORUI (0x4)

foreach ($fontFile in $fontFiles) {
  $fontFileName = $fontFile.Name.ToLower()
  if ($installedFontFiles.ContainsKey($fontFileName)) {
    Write-Verbose "Font file '$($fontFile.Name)' is already installed. Skipping."
    continue
  }
  else {
    Write-Verbose "Installing $($fontFile.Name)..."
    $fontsFolder.CopyHere($fontFile.FullName, $copyHereFlags)
  }
}

Write-Verbose "Font installation process completed."

# Clean up temporary files
Remove-Item $zipPath -Force
Remove-Item $extractPath -Recurse -Force
