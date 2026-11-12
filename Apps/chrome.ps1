param(
    [Parameter(Mandatory = $true)] [string]$PackageId,
    [Parameter(Mandatory = $true)] [string]$DisplayName,
    [Parameter()] [string]$LogPath
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot '..\Modules\InstallHelpers.psm1') -Force
Invoke-WingetInstall -PackageId $PackageId -DisplayName $DisplayName -LogPath $LogPath
