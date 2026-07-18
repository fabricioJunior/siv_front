# Impressão térmica no Mac (Bematech MP-4200 HS)

A Bematech MP-4200 HS é uma impressora térmica ESC/POS. Ela é compartilhada
via SMB por um Windows, e não existe driver nativo Mac funcional pra ela —
mandar PDF direto pro driver do sistema no macOS resulta em texto/comandos
crus impressos na folha em vez do conteúdo.

Solução: converter o PDF pra comandos ESC/POS (raster bit image) e mandar
direto pra fila CUPS em modo raw, sem passar pelo driver.

O app (`MacThermalPrintService`, em
`packages/core/lib/services/mac_thermal_print_service.dart`) já detecta
`Platform.isMacOS` e chama esse script automaticamente. Nada a fazer no
código pra usar — só precisa **instalar o script no Mac** uma vez.

## Setup em um Mac novo — usuário final (recomendado)

Sem terminal, sem digitar comando. Só precisa da pasta `tools/mac_thermal_print`
copiada pro Mac (pendrive, AirDrop, etc — não precisa clonar o repo inteiro).

1. Abra a pasta `tools/mac_thermal_print` no Finder.
2. Dê **duplo-clique** em `Instalar Impressora Termica.command`.
   - Se aparecer aviso "não é possível abrir porque é de um desenvolvedor
     não identificado": clique com o botão direito no arquivo → **Abrir**
     → confirme. Só precisa fazer isso uma vez.
3. Responda as perguntas que aparecem na tela: host do Windows, nome do
   compartilhamento, usuário e senha do Windows.
4. Quando pedir a senha, é a senha de **administrador do Mac** (autorização
   padrão do macOS, não relacionada à impressora).
5. Pronto — testa imprimindo uma nota pelo app.

Pré-requisito: Python 3 instalado. Mac sem Python 3 mostra um aviso
explicando como instalar (`xcode-select --install` no Terminal).

## Setup manual via terminal (alternativa)

```bash
cd tools/mac_thermal_print
./install.sh
./setup_cups_queue.sh
```

- `install.sh` — cria `~/bematech-print/` com um venv Python isolado
  (pymupdf + pillow) e o script `print_pdf.sh`. Esse caminho é fixo — o
  app sempre chama `$HOME/bematech-print/print_pdf.sh`.
- `setup_cups_queue.sh` — pede host do Windows, nome do compartilhamento e
  credencial, e cria a fila CUPS `MP4200HS` com a credencial embutida na
  URI (evita prompt de autenticação do Keychain, que trava os jobs).

O `.command` acima faz exatamente a mesma coisa que esses dois scripts,
só que com janelas em vez de terminal.

## Testar manualmente

```bash
~/bematech-print/print_pdf.sh caminho/do/arquivo.pdf
```

Ou sem gastar bobina, só gerar os bytes:

```bash
~/bematech-print/print_pdf.sh caminho/do/arquivo.pdf --dry-run saida.bin
```

## Parâmetros do script

- `--queue NOME` — fila CUPS (padrão `MP4200HS`)
- `--width 384|576` — largura em dots: 384 = bobina 58mm, 576 = bobina
  80mm (padrão, é a bobina em uso)
- `--dpi 203` — resolução de renderização (padrão, resolução nativa da
  MP-4200 HS)

## Problemas conhecidos

- **Job fica "waiting for job to complete" travado**: geralmente é
  credencial SMB expirada (`smbutil view "smb://usuario@host"` retorna
  erro de autenticação) ou a impressora em estado de erro do lado do
  Windows (offline, sem papel, tampa aberta, fila pausada) — o status
  `0x0x000002` no log do CUPS (`/var/log/cups/error_log`) é o código de
  erro reportado pelo Windows Print Spooler (`PRINTER_STATUS_ERROR`).
  Não é problema do script/fila Mac nesses casos.
- Se a credencial mudar, rode `./setup_cups_queue.sh` de novo.
