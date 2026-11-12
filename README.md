# Automa��oThata

Estrutura do projeto:
- Apps/: scripts específicos para cada aplicativo
- Scripts/: rotinas de manutenção e utilitários do Windows
- Modules/: módulos reutilizáveis para instalação e logging
- Logs/: registros de execução e erros

## Como usar
1. Edite o arquivo apps.json para incluir ou remover aplicativos do catálogo.
2. Execute o instalador:
   powershell -ExecutionPolicy Bypass -File .\install.ps1
3. Digite os números dos programas desejados, por exemplo: 1,2,4

## Fluxo
- O instalador lê o catálogo do arquivo apps.json.
- Ele exibe um menu interativo com os aplicativos disponíveis.
- Cada item é encaminhado para um script em Apps/ quando necessário.
- A instalação é executada via winget, com logs salvos em Logs/.
