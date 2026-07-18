import 'dart:typed_data';

import 'package:comercial/domain/models/danfe.dart';
import 'package:comercial/presentation/relatorios/danfe/danfe_layout.dart';
import 'package:core/pdf.dart' show PdfPageFormat, PdfColors;
import 'package:core/pdf_widgets.dart' as pw;

/// Renderiza o DANFE em PDF (rolo continuo 58mm ou 80mm) a partir da mesma
/// arvore de nodes usada pelo renderer ESC/POS (`danfe_esc_pos_renderer.dart`).
class DanfePdfRenderer {
  DanfePdfRenderer._();

  static Future<Uint8List> render(
    DanfeLayoutData dados, {
    PdfPageFormat pageFormat = PdfPageFormat.roll80,
  }) async {
    final doc = pw.Document();
    final nodes = construirDanfeNodes(dados);

    doc.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [for (final node in nodes) _widgetPara(node)],
        ),
      ),
    );

    return doc.save();
  }

  static pw.Widget _widgetPara(DanfeNode node) => switch (node) {
        DanfeTexto texto => pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 1),
            child: pw.Container(
              width: double.infinity,
              alignment: _alignmentPdf(texto.alinhamento),
              child: pw.Text(
                texto.texto,
                textAlign: _alinhamentoPdf(texto.alinhamento),
                style: pw.TextStyle(
                  fontSize: 9 * texto.escala,
                  fontWeight: texto.negrito ? pw.FontWeight.bold : pw.FontWeight.normal,
                ),
              ),
            ),
          ),
        DanfeLinhaDupla linha => pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 1),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Text(
                    linha.esquerda,
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: linha.negrito ? pw.FontWeight.bold : pw.FontWeight.normal,
                    ),
                  ),
                ),
                pw.SizedBox(width: 6),
                pw.Text(
                  linha.direita,
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: linha.negrito ? pw.FontWeight.bold : pw.FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        DanfeSeparador() => pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 2),
            child: pw.Divider(color: PdfColors.grey700, thickness: 0.5),
          ),
        DanfeEspaco espaco => pw.SizedBox(height: 6.0 * espaco.linhas),
        DanfeQrCode qr => pw.Center(
            child: pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 4),
              child: pw.BarcodeWidget(
                barcode: pw.Barcode.qrCode(),
                data: qr.dado,
                width: 100,
                height: 100,
              ),
            ),
          ),
      };

  static pw.TextAlign _alinhamentoPdf(DanfeAlinhamento alinhamento) => switch (alinhamento) {
        DanfeAlinhamento.esquerda => pw.TextAlign.left,
        DanfeAlinhamento.centro => pw.TextAlign.center,
        DanfeAlinhamento.direita => pw.TextAlign.right,
      };

  static pw.Alignment _alignmentPdf(DanfeAlinhamento alinhamento) => switch (alinhamento) {
        DanfeAlinhamento.esquerda => pw.Alignment.centerLeft,
        DanfeAlinhamento.centro => pw.Alignment.center,
        DanfeAlinhamento.direita => pw.Alignment.centerRight,
      };
}
