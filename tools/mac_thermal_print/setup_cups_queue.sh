#!/bin/bash
# Cria/recria a fila CUPS "MP4200HS" apontando para a impressora térmica
# compartilhada via SMB no Windows, com a credencial embutida na URI
# (evita o prompt de autenticação do Keychain, que trava jobs de impressão).
#
# Uso: ./setup_cups_queue.sh
# Pede sudo -- precisa rodar interativamente (não via automação).

set -euo pipefail

NOME_FILA="MP4200HS"

read -rp "Host/IP do Windows (ex: desktop-mqoo42o.local): " HOST_WINDOWS
read -rp "Nome do compartilhamento da impressora no Windows (ex: MP4200HS): " NOME_SHARE
read -rp "Usuário do Windows: " USUARIO
read -rsp "Senha do Windows: " SENHA
echo ""

USUARIO_ENC="$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$USUARIO")"
SENHA_ENC="$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$SENHA")"

URI="smb://${USUARIO_ENC}:${SENHA_ENC}@${HOST_WINDOWS}/${NOME_SHARE}"

echo "Removendo fila antiga (se existir)..."
sudo lpadmin -x "$NOME_FILA" 2>/dev/null || true

echo "Criando fila '$NOME_FILA'..."
# macOS não aceita mais fila "raw" pura (-m raw) -- usamos um driver
# genérico qualquer só pra satisfazer o lpadmin. Todo job enviado com
# "lp -o raw" (é o que o script/app fazem) ignora esse driver e manda os
# bytes direto, sem reprocessar.
sudo lpadmin -p "$NOME_FILA" -E -v "$URI" -m "drv:///sample.drv/generic.ppd"

echo "OK. Fila '$NOME_FILA' criada."
echo ""
echo "Teste com:"
echo "  echo teste | lp -d $NOME_FILA -o raw"
