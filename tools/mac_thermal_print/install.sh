#!/bin/bash
# Instala o conversor PDF -> ESC/POS em qualquer Mac.
#
# O app (MacThermalPrintService) sempre chama
# "$HOME/bematech-print/print_pdf.sh", então essa é a pasta de destino fixa
# -- não mude sem atualizar packages/core/lib/services/mac_thermal_print_service.dart.
#
# Uso: ./install.sh

set -euo pipefail

DIR_ORIGEM="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIR_DESTINO="$HOME/bematech-print"

echo "Instalando conversor PDF -> ESC/POS em $DIR_DESTINO ..."

mkdir -p "$DIR_DESTINO"
cp "$DIR_ORIGEM/pdf_to_escpos.py" "$DIR_DESTINO/pdf_to_escpos.py"
chmod +x "$DIR_DESTINO/pdf_to_escpos.py"

if [ ! -d "$DIR_DESTINO/venv" ]; then
  echo "Criando ambiente virtual Python..."
  python3 -m venv "$DIR_DESTINO/venv"
fi

echo "Instalando dependências (pymupdf, pillow)..."
"$DIR_DESTINO/venv/bin/pip" install --quiet -r "$DIR_ORIGEM/requirements.txt"

cat > "$DIR_DESTINO/print_pdf.sh" << 'EOF'
#!/bin/bash
# Wrapper: chama o conversor com o venv certo.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$DIR/venv/bin/python3" "$DIR/pdf_to_escpos.py" "$@"
EOF
chmod +x "$DIR_DESTINO/print_pdf.sh"

echo "OK. Script instalado em $DIR_DESTINO/print_pdf.sh"
echo ""
echo "Próximo passo: configurar a fila de impressão no CUPS."
echo "Rode: ./setup_cups_queue.sh"
