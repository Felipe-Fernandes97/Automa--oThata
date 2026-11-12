param(
    [string]$Selection
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$null = [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$null = [Console]::InputEncoding = [System.Text.UTF8Encoding]::new()

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$configPath = Join-Path $root 'apps.json'
$logsDirectory = Join-Path $root 'Logs'
New-Item -ItemType Directory -Force -Path $logsDirectory | Out-Null

if (-not (Test-Path $configPath)) {
    throw "Arquivo apps.json não encontrado em $configPath."
}

$modulePath = Join-Path $root 'Modules/InstallHelpers.psm1'
Import-Module $modulePath -Force

$config = Get-Content -Path $configPath -Raw | ConvertFrom-Json
$apps = @()

foreach ($property in $config.PSObject.Properties) {
    $value = $property.Value
    $apps += [pscustomobject]@{
        Key = $property.Name
        Name = if ($value.PSObject.Properties.Name -contains 'name') { [string]$value.name } else { [string]$property.Name }
        Id = [string]$value.id
        Script = if ($value.PSObject.Properties.Name -contains 'script') { [string]$value.script } else { [string]$property.Name }
    }
}

Write-Host '================================'
Write-Host '      WINDOWS AUTOMATION'
Write-Host '================================'
Write-Host ''
Write-Host 'Aplicativos disponiveis:'

for ($i = 0; $i -lt $apps.Count; $i++) {
    $app = $apps[$i]
    Write-Host ("[{0}] {1}" -f ($i + 1), $app.Name)
}

Write-Host ''

if ($Selection) {
    $selectedNumbers = $Selection -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
} else {
    $selectedNumbers = (Read-Host 'Digite os numeros dos aplicativos').Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
}

$selectedApps = @()
foreach ($item in $selectedNumbers) {
    if ($item -match '^\d+$') {
        $index = [int]$item - 1
        if ($index -ge 0 -and $index -lt $apps.Count) {
            $selectedApps += $apps[$index]
        } else {
            Write-Warning "Opção inválida: $item"
        }
    } else {
        Write-Warning "Entrada inválida: $item"
    }
}

if ($selectedApps.Count -eq 0) {
    Write-Host 'Nenhum aplicativo selecionado.'
    return
}

$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$logFile = Join-Path $logsDirectory ("install-{0}.log" -f $timestamp)

foreach ($app in $selectedApps) {
    Write-Host ''
    Write-Host ("Instalando {0}..." -f $app.Name)
    $scriptPath = Join-Path $root ("Apps/{0}.ps1" -f $app.Script)

    if (Test-Path $scriptPath) {
        & $scriptPath -PackageId $app.Id -DisplayName $app.Name -LogPath $logFile
    } else {
        Write-Warning ("Script nao encontrado para {0}. Usando instalacao padrao via winget." -f $app.Name)
        Invoke-WingetInstall -PackageId $app.Id -DisplayName $app.Name -LogPath $logFile
    }

    Write-Host 'Concluido'
}
