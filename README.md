# AutomacaoThata

Automacao para a equipe de suporte instalar o NutriSmart no computador do cliente. No fluxo remoto, o cliente nao precisa clonar o repositorio nem manter os arquivos da automacao instalados.

## Uso no computador do cliente

### Antes de executar o comando

1. A pessoa de suporte transfere pelo Bomgar o instalador do NutriSmart para a pasta temporaria do Windows do usuario (`%TEMP%`).

2. O arquivo deve ser um MSI e o nome deve comecar com `NutriSmart` e terminar com `.msi`, por exemplo `NutriSmart_formul_v4.msi`.

3. Deve haver exatamente um arquivo que corresponda a `NutriSmart*.msi` nessa pasta. Se houver uma versao antiga junto com a nova, mova ou remova a antiga antes de prosseguir.

4. A automacao precisa estar publicada em um repositorio publico do GitHub, e a URL no comando e em `Start-Automacao.ps1` precisa apontar para esse repositorio.

5. O computador precisa de acesso a internet. A instalacao pode exigir permissao administrativa.

### Executar a automacao

No computador do cliente, abra o CMD e cole o comando abaixo. Ele baixa o inicializador do GitHub para `%TEMP%`, executa-o e remove esse arquivo inicializador ao terminar:

```cmd
powershell -NoProfile -ExecutionPolicy Bypass -Command "$p=Join-Path $env:TEMP ('AutomacaoThata-Start-' + [guid]::NewGuid().ToString('N') + '.ps1'); try { Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/Felipe-Fernandes97/Automa--oThata/main/Start-Automacao.ps1' -OutFile $p; & $p } finally { Remove-Item -LiteralPath $p -Force -ErrorAction SilentlyContinue }"
```

O inicializador baixa o restante do projeto para uma pasta temporaria, abre o menu e executa `install.ps1`. No menu, digite `1` para selecionar NutriSmart. A automacao procura o MSI em `%TEMP%` e inicia a instalacao silenciosa.

Ao terminar, os arquivos temporarios baixados para executar a automacao sao removidos. O MSI transferido pelo Bomgar e o aplicativo instalado nao sao apagados.

### O que esperar

- O comando remoto e para o cliente que nao tem os arquivos do repositorio. Ele precisa do MSI transferido pelo Bomgar, mas nao precisa do codigo da automacao previamente.

- O `msiexec` e executado com `/qn /norestart`; isso nao simula cliques em Next/Install/Finish. O MSI precisa suportar instalacao silenciosa.

- A instalacao ou atualizacao de uma versao ja existente depende de como o MSI foi criado. A automacao nao garante que o instalador atualize uma versao anterior.

- Se a URL do repositorio estiver incorreta, o repositorio nao estiver publico, ou o cliente nao tiver internet, o download da automacao falha.

- Use o comando somente para baixar codigo do repositorio oficial e revisado pela equipe.

## Execucao local e desenvolvimento

Este comando e diferente do comando remoto acima. Use-o somente quando os arquivos completos do projeto ja estiverem na maquina e o terminal estiver aberto na pasta do projeto:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

Se o cliente tiver apenas o MSI, mas nao os arquivos da automacao, este comando local nao funciona. Nesse caso, use o comando remoto depois de publicar e validar o repositorio.

Edite `apps.json` para configurar os aplicativos apresentados no menu. O NutriSmart usa o padrao de arquivo MSI `NutriSmart*.msi`.
