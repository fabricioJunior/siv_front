#!/usr/bin/env python3
"""
Converte um PDF em comandos ESC/POS (raster bit image) e envia para a
impressora térmica Bematech MP-4200 HS via fila CUPS (modo raw).

Uso:
    pdf_to_escpos.py documento.pdf [--queue MP4200HS] [--width 576] [--dpi 203] [--dry-run saida.bin]

--width: largura imprimível em dots.
    384 -> bobina 58mm
    576 -> bobina 80mm (padrão)
--dry-run: em vez de enviar para a impressora, grava os bytes ESC/POS
    no arquivo indicado (útil para testar sem gastar bobina).
"""

import argparse
import subprocess
import sys

import fitz  # pymupdf
from PIL import Image

ESC = b"\x1b"
GS = b"\x1d"

INIT_PRINTER = ESC + b"@"
CUT_PAPER = GS + b"V" + b"\x00"

# Máximo de linhas (dots de altura) por comando de raster para não estourar
# o buffer da impressora.
MAX_BAND_HEIGHT = 256


def pdf_paginas_para_imagens(caminho_pdf: str, largura_dots: int, dpi: int) -> list[Image.Image]:
    doc = fitz.open(caminho_pdf)
    imagens = []
    for pagina in doc:
        zoom = dpi / 72.0
        matriz = fitz.Matrix(zoom, zoom)
        pix = pagina.get_pixmap(matrix=matriz, colorspace=fitz.csGRAY)
        img = Image.frombytes("L", (pix.width, pix.height), pix.samples)

        if img.width != largura_dots:
            nova_altura = round(img.height * (largura_dots / img.width))
            img = img.resize((largura_dots, nova_altura), Image.LANCZOS)

        imagens.append(img)
    return imagens


def imagem_para_1bit(img: Image.Image) -> Image.Image:
    return img.convert("1", dither=Image.FLOYDSTEINBERG)


def imagem_1bit_para_escpos(img_1bit: Image.Image) -> bytes:
    largura, altura = img_1bit.size
    bytes_por_linha = (largura + 7) // 8
    pixels = img_1bit.load()

    saida = bytearray()

    for topo in range(0, altura, MAX_BAND_HEIGHT):
        banda_altura = min(MAX_BAND_HEIGHT, altura - topo)
        dados_banda = bytearray(bytes_por_linha * banda_altura)

        for y in range(banda_altura):
            linha_y = topo + y
            for x in range(largura):
                # PIL modo "1": 0 = preto, 255 = branco.
                if pixels[x, linha_y] == 0:
                    byte_idx = y * bytes_por_linha + (x // 8)
                    bit_idx = 7 - (x % 8)
                    dados_banda[byte_idx] |= (1 << bit_idx)

        xL = bytes_por_linha & 0xFF
        xH = (bytes_por_linha >> 8) & 0xFF
        yL = banda_altura & 0xFF
        yH = (banda_altura >> 8) & 0xFF

        saida += GS + b"v0" + b"\x00" + bytes([xL, xH, yL, yH]) + bytes(dados_banda)

    return bytes(saida)


def gerar_escpos(caminho_pdf: str, largura_dots: int, dpi: int) -> bytes:
    saida = bytearray()
    saida += INIT_PRINTER

    for img in pdf_paginas_para_imagens(caminho_pdf, largura_dots, dpi):
        img_1bit = imagem_para_1bit(img)
        saida += imagem_1bit_para_escpos(img_1bit)

    saida += b"\n\n\n"
    saida += CUT_PAPER
    return bytes(saida)


def enviar_para_impressora(dados: bytes, fila: str) -> None:
    processo = subprocess.run(
        ["lp", "-d", fila, "-o", "raw"],
        input=dados,
        capture_output=True,
    )
    if processo.returncode != 0:
        print(f"Erro ao enviar para a fila '{fila}':", file=sys.stderr)
        print(processo.stderr.decode(errors="replace"), file=sys.stderr)
        sys.exit(1)
    print(processo.stdout.decode(errors="replace").strip() or "Enviado para impressão.")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("pdf", help="Caminho do PDF a imprimir")
    parser.add_argument("--queue", default="MP4200HS", help="Nome da fila CUPS (padrão: MP4200HS)")
    parser.add_argument("--width", type=int, default=576, help="Largura em dots: 384 (58mm) ou 576 (80mm)")
    parser.add_argument("--dpi", type=int, default=203, help="DPI de renderização (padrão: 203, resolução da MP-4200 HS)")
    parser.add_argument("--dry-run", metavar="ARQUIVO", help="Grava bytes ESC/POS em arquivo em vez de imprimir")
    args = parser.parse_args()

    dados = gerar_escpos(args.pdf, args.width, args.dpi)

    if args.dry_run:
        with open(args.dry_run, "wb") as f:
            f.write(dados)
        print(f"Bytes ESC/POS gravados em {args.dry_run} ({len(dados)} bytes)")
    else:
        enviar_para_impressora(dados, args.queue)


if __name__ == "__main__":
    main()
