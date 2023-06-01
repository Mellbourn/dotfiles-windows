[CmdletBinding()] param (
     [Parameter()]
     [SupportsWildcards()]
     [string]$Path = "$env:OneDrive\Bilder\Screenshots",

     [Parameter()]
     [ValidateRange("NonNegative")]
     [int]$daysOld = 14
)
$ErrorActionPreference = "Stop"

Get-ChildItem -Path $Path -Recurse -Force
    | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$daysOld) }
    | Remove-ItemSafely
