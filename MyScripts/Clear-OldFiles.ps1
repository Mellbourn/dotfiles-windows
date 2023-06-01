[CmdletBinding()] param (
     [Parameter()]
     [SupportsWildcards()]
     [string]$Path = "$env:OneDrive\Bilder\Screenshots",

     [Parameter()]
     [ValidateRange("NonNegative")]
     [int]$DaysOld = 14
)
$ErrorActionPreference = "Stop"

Get-ChildItem -Path $Path -Recurse -Force
    | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$DaysOld) }
    | Remove-ItemSafely
