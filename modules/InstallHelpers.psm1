function Invoke-WingetInstall {
    param(
        [Parameter(Mandatory = $true)] [string]$PackageId,
        [Parameter(Mandatory = $true)] [string]$DisplayName,
        [Parameter()] [string]$LogPath
    )

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logEntry = "[{0}] Instalando {1} ({2})" -f $timestamp, $DisplayName, $PackageId

    if ($LogPath) {
        Add-Content -Path $LogPath -Value $logEntry
    }

    Write-Host ("Instalando via winget: {0}" -f $DisplayName)

    try {
        winget install --id $PackageId --accept-source-agreements --accept-package-agreements --silent | Out-Null
        $successEntry = "[{0}] SUCESSO: {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $DisplayName
        if ($LogPath) {
            Add-Content -Path $LogPath -Value $successEntry
        }
    } catch {
        $errorEntry = "[{0}] ERRO: {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $_.Exception.Message
        if ($LogPath) {
            Add-Content -Path $LogPath -Value $errorEntry
        }
        throw
    }
}

Export-ModuleMember -Function Invoke-WingetInstall
