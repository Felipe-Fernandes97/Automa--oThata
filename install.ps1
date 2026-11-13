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
    $installerProperty = $value.PSObject.Properties['installer']
    $installer = if ($installerProperty) { $installerProperty.Value } else { $null }
    $apps += [pscustomobject]@{
        Key = $property.Name
        Name = if ($value.PSObject.Properties.Name -contains 'name') { [string]$value.name } else { [string]$property.Name }
        Id = if ($value.PSObject.Properties.Name -contains 'id') { [string]$value.id } else { '' }
        Script = if ($value.PSObject.Properties.Name -contains 'script') { [string]$value.script } else { [string]$property.Name }
        InstallerType = if ($installer -and $installer.PSObject.Properties.Name -contains 'type') { [string]$installer.type } else { '' }
        InstallerPattern = if ($installer -and $installer.PSObject.Properties.Name -contains 'pattern') { [string]$installer.pattern } else { '' }
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

    if ($app.InstallerType -eq 'msi') {
        if ([string]::IsNullOrWhiteSpace($app.InstallerPattern)) {
            throw "Padrão do instalador MSI não configurado para $($app.Name)."
        }

        $installerFiles = @(Get-ChildItem -LiteralPath $env:TEMP -Filter $app.InstallerPattern -File)
        if ($installerFiles.Count -eq 0) {
            throw "Nenhum instalador encontrado em $env:TEMP com o padrão '$($app.InstallerPattern)'. Transfira o MSI pelo Bomgar antes de executar a automação."
        }
        if ($installerFiles.Count -gt 1) {
            throw "Foram encontrados vários instaladores para $($app.Name) em $env:TEMP. Deixe somente o MSI da versão desejada e execute novamente."
        }

        Invoke-MsiInstall -MsiPath $installerFiles[0].FullName -DisplayName $app.Name -LogPath $logFile
    } else {
        $scriptPath = Join-Path $root ("Apps/{0}.ps1" -f $app.Script)
        if (Test-Path $scriptPath) {
            & $scriptPath -PackageId $app.Id -DisplayName $app.Name -LogPath $logFile
        } else {
            if ([string]::IsNullOrWhiteSpace($app.Id)) {
                throw "ID do pacote winget não configurado para $($app.Name)."
            }
            Write-Warning ("Script nao encontrado para {0}. Usando instalacao padrao via winget." -f $app.Name)
            Invoke-WingetInstall -PackageId $app.Id -DisplayName $app.Name -LogPath $logFile
        }
    }

    Write-Host 'Concluido'
}
