$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repositoryArchive = 'https://github.com/Felipe-Fernandes97/Automa--oThata/archive/refs/heads/main.zip'
$workingDirectory = Join-Path $env:TEMP ("AutomacaoThata-{0}" -f [guid]::NewGuid().ToString('N'))
$archivePath = Join-Path $workingDirectory 'source.zip'

try {
    New-Item -ItemType Directory -Path $workingDirectory -Force | Out-Null
    Write-Host 'Baixando os arquivos temporarios da automacao...'
    Invoke-WebRequest -Uri $repositoryArchive -OutFile $archivePath -UseBasicParsing
    Expand-Archive -LiteralPath $archivePath -DestinationPath $workingDirectory -Force

    $installerScript = Get-ChildItem -LiteralPath $workingDirectory -Filter 'install.ps1' -File -Recurse |
        Select-Object -First 1
    if (-not $installerScript) {
        throw 'O pacote baixado nao contem install.ps1.'
    }

    & $installerScript.FullName
    if (-not $?) {
        throw 'A automacao terminou com erro.'
    }
} finally {
    if (Test-Path -LiteralPath $workingDirectory) {
        Remove-Item -LiteralPath $workingDirectory -Recurse -Force
    }
}
