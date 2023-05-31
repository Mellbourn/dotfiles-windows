[CmdletBinding()] param ()
$ErrorActionPreference = "Stop"

if ((Get-PSRepository -Name PSGallery).InstallationPolicy -ne 'Trusted') {
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
}
Write-Verbose "Install modules"
$ModuleListString = "
# Remove-ItemSafely, i.e. deletion by moving to the trash
Recycle

# add icons to ls, like lsd
Terminal-Icons

# unix-like environment
z,PSFzf

# this is needed only for command line completion in PSFzf
posh-git
"
# Weirdly, listing the modules is more reliable than Get-Module or Get-InstalledModule
$GetModuleList = (Get-ChildItem $PSScriptRoot\..\Modules).Name
$ModuleList = $ModuleListString -split "`n"
foreach ($ModuleLineString in $ModuleList) {
    $ModuleLine = $ModuleLineString.Trim()
    if ($ModuleLine -ne "" -and $ModuleLine -notlike "#*") {
        $ModuleArray = $ModuleLine.Split(",")
        foreach ($ModuleWithSpace in $ModuleArray) {
            $Module = $ModuleWithSpace.Trim()
            if ($Module -ne "" -and (-Not ($GetModuleList.Contains($Module)))) {
                Write-Verbose "Installing '$Module'"
                Install-Module -Name $Module -Repository PSGallery -Scope CurrentUser
            }
        }
    }
}
