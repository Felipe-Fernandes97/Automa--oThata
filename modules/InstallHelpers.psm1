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

function Invoke-MsiInstall {
    param(
        [Parameter(Mandatory = $true)] [string]$MsiPath,
        [Parameter(Mandatory = $true)] [string]$DisplayName,
        [Parameter()] [string]$LogPath
    )

    $installEntry = "[{0}] Instalando {1} pelo MSI: {2}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $DisplayName, $MsiPath
    if ($LogPath) {
        Add-Content -Path $LogPath -Value $installEntry
    }

    Write-Host ("Instalando {0} silenciosamente. O instalador MSI permanece na pasta temporaria." -f $DisplayName)
    $process = Start-Process -FilePath 'msiexec.exe' -ArgumentList @('/i', ('"{0}"' -f $MsiPath), '/qn', '/norestart') -Wait -PassThru

    if ($process.ExitCode -notin @(0, 3010)) {
        $errorMessage = "A instalacao de $DisplayName falhou. Codigo de saida do Windows Installer: $($process.ExitCode)."
        if ($LogPath) {
            Add-Content -Path $LogPath -Value ("[{0}] ERRO: {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $errorMessage)
        }
        throw $errorMessage
    }

    $status = if ($process.ExitCode -eq 3010) { 'SUCESSO; reinicializacao necessaria' } else { 'SUCESSO' }
    if ($LogPath) {
        Add-Content -Path $LogPath -Value ("[{0}] {1}: {2}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $status, $DisplayName)
    }
    if ($process.ExitCode -eq 3010) {
        Write-Warning 'Instalacao concluida. O Windows solicitou uma reinicializacao.'
    }
}

Export-ModuleMember -Function Invoke-WingetInstall, Invoke-MsiInstall
