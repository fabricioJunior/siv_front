#!/bin/bash
# Duplo-clique nesse arquivo instala e configura tudo -- sem precisar
# digitar comando nenhum no Terminal. Usa janelas nativas do macOS pra
# pedir os dados da impressora e a senha de administrador.

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NOME_FILA="MP4200HS"

alerta() {
  osascript -e "display alert \"$1\" message \"$2\" as critical buttons {\"OK\"} default button 1" >/dev/null
}

if ! command -v python3 >/dev/null 2>&1; then
  alerta "Python 3 não encontrado" "Abra o Terminal, rode: xcode-select --install\nDepois de instalar, dê duplo-clique nesse arquivo de novo."
  exit 1
fi

osascript -e 'display dialog "Vamos configurar a impressão da nota fiscal nesse Mac.\n\nVocê vai precisar do usuário e senha do computador Windows onde a impressora térmica está compartilhada." with title "Instalador — Impressora Térmica" buttons {"Continuar"} default button 1' >/dev/null

HOST=$(osascript -e 'text returned of (display dialog "Nome ou IP do computador Windows:" default answer "desktop-mqoo42o.local" with title "Instalador — Impressora Térmica")') || exit 0
SHARE=$(osascript -e 'text returned of (display dialog "Nome do compartilhamento da impressora no Windows:" default answer "MP4200HS" with title "Instalador — Impressora Térmica")') || exit 0
USUARIO=$(osascript -e 'text returned of (display dialog "Usuário do Windows:" default answer "" with title "Instalador — Impressora Térmica")') || exit 0
SENHA=$(osascript -e 'text returned of (display dialog "Senha do Windows:" default answer "" with hidden answer true with title "Instalador — Impressora Térmica")') || exit 0

echo "Instalando conversor PDF -> ESC/POS..."
bash "$DIR/install.sh"

USUARIO_ENC="$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$USUARIO")"
SENHA_ENC="$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$SENHA")"
HOST_ENC="$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1], safe='.'))" "$HOST")"
SHARE_ENC="$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$SHARE")"

URI="smb://${USUARIO_ENC}:${SENHA_ENC}@${HOST_ENC}/${SHARE_ENC}"

echo "Configurando fila de impressão (vai pedir sua senha de administrador do Mac)..."
if ! osascript -e "do shell script \"lpadmin -x $NOME_FILA >/dev/null 2>&1; lpadmin -p $NOME_FILA -E -v '$URI' -m 'drv:///sample.drv/generic.ppd'\" with administrator privileges"; then
  alerta "Erro ao configurar a impressora" "Não foi possível criar a fila de impressão. Confira o host, usuário e senha e tente de novo."
  exit 1
fi

osascript -e 'display alert "Instalação concluída" message "A impressão térmica está configurada nesse Mac. Teste imprimindo uma nota fiscal pelo app." buttons {"OK"} default button 1' >/dev/null

echo "Concluído."
