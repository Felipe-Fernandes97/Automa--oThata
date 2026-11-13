# AutomacaoThata

Automacao para a equipe de suporte instalar o NutriSmart no computador do cliente sem clonar ou instalar permanentemente este repositorio.

## Fluxo no computador do cliente

1. A pessoa de suporte transfere pelo Bomgar um unico instalador MSI do NutriSmart para a pasta temporaria do Windows do usuario (`%TEMP%`). O nome do arquivo deve comecar com `NutriSmart` e terminar com `.msi`, por exemplo `NutriSmart_formul_v4.msi`.
2. No CMD do computador do cliente, executa o comando abaixo. Ele baixa a automacao publicada no GitHub para uma pasta temporaria e abre o menu.
3. Seleciona `1` para instalar o NutriSmart.
4. A automacao executa o MSI em modo silencioso, sem exibir o assistente de Next/Install/Finish.
5. Ao terminar, os arquivos temporarios baixados da automacao sao removidos. O aplicativo instalado e o MSI transferido pelo Bomgar nao sao apagados.

```cmd
powershell -NoProfile -ExecutionPolicy Bypass -Command "$p=Join-Path $env:TEMP ('AutomacaoThata-Start-' + [guid]::NewGuid().ToString('N') + '.ps1'); try { Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/Felipe-Fernandes97/Automa--oThata/main/Start-Automacao.ps1' -OutFile $p; & $p } finally { Remove-Item -LiteralPath $p -Force -ErrorAction SilentlyContinue }"
```

O comando exige internet, acesso ao repositorio publico e Windows PowerShell 5.1. Como ele baixa e executa codigo, use-o somente com a URL oficial do projeto e apos publicar/revisar os arquivos no GitHub.

## Regras do instalador

- O MSI deve estar em `%TEMP%` e seu nome deve corresponder a `NutriSmart*.msi`.
- Deve existir exatamente um MSI correspondente. Se nao houver nenhum, transfira o arquivo pelo Bomgar. Se houver mais de um, remova ou mova a versao antiga antes de executar.
- A automacao chama `msiexec` com `/qn /norestart`, portanto nao simula cliques. O MSI precisa aceitar instalacao silenciosa.
- Atualizar uma versao ja instalada depende de o pacote MSI ter sido preparado para atualizar a versao anterior. O comando de instalacao, sozinho, nao garante esse comportamento.
- Se a instalacao exigir privilegios administrativos, o Windows pode solicitar elevacao ou a instalacao pode falhar conforme as permissoes da sessao de suporte.

## Desenvolvimento

Edite `apps.json` para configurar os aplicativos apresentados no menu. Para o NutriSmart, o padrao de arquivo MSI e configurado como `NutriSmart*.msi`.

Para executar localmente, a partir da pasta completa do projeto:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```
