import 'dart:typed_data';

import 'package:comercial/presentation/relatorios/danfe/danfe_pdf_renderer.dart';
import 'package:core/pdf.dart' show PdfPageFormat;
import 'package:core/pdf_widgets.dart' as pw;

/// Item exibido na Nota de Entrega (nome/descricao do produto + valor).
class NotaEntregaItem {
  final String descricao;
  final double? valor;

  const NotaEntregaItem({required this.descricao, this.valor});
}

/// Dados fiscais da nota, exibidos somente quando a NFe foi autorizada com
/// sucesso -- ver [NotaEntregaLayoutData.dadosFiscais].
class NotaEntregaDadosFiscais {
  final String? numeroNota;
  final String? protocolo;
  final String? qrCodeUrl;

  const NotaEntregaDadosFiscais({
    this.numeroNota,
    this.protocolo,
    this.qrCodeUrl,
  });
}

/// Dados necessarios pra renderizar a Nota de Entrega -- documento voltado
/// pro entregador, com destaque pro endereco e nome do cliente (fonte bem
/// maior que o restante), diferente do DANFE.
class NotaEntregaLayoutData {
  final String enderecoFormatado;
  final String nomeCliente;
  final DateTime? dataCompra;
  final int? numeroRomaneio;
  // Rótulo da linha de identificação do documento (ex: "Romaneio", "Pedido") --
  // a nota de entrega pode ser gerada tanto a partir de um romaneio (venda já
  // faturada) quanto de um pedido ainda em andamento (entrega precisa sair
  // antes do faturamento), então o rótulo não pode ficar fixo em "Romaneio".
  final String rotuloNumero;
  final String empresaNome;
  final String? empresaCnpj;
  final List<NotaEntregaItem> itens;

  /// `null` quando a NFe nao foi autorizada (falha na emissao ou ainda sem
  /// documento fiscal) -- nesse caso os campos fiscais (numero, protocolo,
  /// QR code) simplesmente nao sao renderizados.
  final NotaEntregaDadosFiscais? dadosFiscais;

  const NotaEntregaLayoutData({
    required this.enderecoFormatado,
    required this.nomeCliente,
    this.dataCompra,
    this.numeroRomaneio,
    this.rotuloNumero = 'Romaneio',
    required this.empresaNome,
    this.empresaCnpj,
    this.itens = const [],
    this.dadosFiscais,
  });
}

class NotaEntregaPdfRenderer {
  NotaEntregaPdfRenderer._();

  static Future<Uint8List> render(
    NotaEntregaLayoutData dados, {
    PdfPageFormat pageFormat = DanfePdfRenderer.roll80Seguro,
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                'NOTA DE ENTREGA',
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Divider(thickness: 0.7),
            pw.SizedBox(height: 4),
            pw.Text(
              dados.nomeCliente,
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Divider(thickness: 0.7),
            pw.SizedBox(height: 8),
            pw.Text(
              dados.enderecoFormatado,
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Divider(thickness: 0.7),
            pw.SizedBox(height: 4),
            pw.Text(
              '${dados.rotuloNumero}: #${dados.numeroRomaneio ?? '-'}',
              style: const pw.TextStyle(fontSize: 9),
            ),
            pw.Text(
              'Horário da compra: ${_fmtDataHora(dados.dataCompra)}',
              style: const pw.TextStyle(fontSize: 9),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              dados.empresaNome,
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
            ),
            if ((dados.empresaCnpj ?? '').trim().isNotEmpty)
              pw.Text(
                'CNPJ: ${dados.empresaCnpj}',
                style: const pw.TextStyle(fontSize: 9),
              ),
            pw.SizedBox(height: 8),
            pw.Divider(thickness: 0.7),
            pw.Text(
              'Itens',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            for (final item in dados.itens)
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 1),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        item.descricao,
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ),
                    pw.SizedBox(width: 6),
                    pw.Text(
                      _fmtMoeda(item.valor),
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ],
                ),
              ),
            if (dados.dadosFiscais != null) ...[
              pw.SizedBox(height: 8),
              pw.Divider(thickness: 0.7),
              if ((dados.dadosFiscais!.numeroNota ?? '').trim().isNotEmpty)
                pw.Text(
                  'Nota fiscal nº ${dados.dadosFiscais!.numeroNota}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              if ((dados.dadosFiscais!.protocolo ?? '').trim().isNotEmpty)
                pw.Text(
                  'Protocolo: ${dados.dadosFiscais!.protocolo}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              if ((dados.dadosFiscais!.qrCodeUrl ?? '').trim().isNotEmpty)
                pw.Center(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: dados.dadosFiscais!.qrCodeUrl!,
                      width: 90,
                      height: 90,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );

    return doc.save();
  }

  static String _fmtMoeda(double? valor) {
    final v = (valor ?? 0).toStringAsFixed(2);
    return 'R\$ ${v.replaceAll('.', ',')}';
  }

  static String _fmtDataHora(DateTime? data) {
    if (data == null) return '-';
    final local = data.toLocal();
    final dia = local.day.toString().padLeft(2, '0');
    final mes = local.month.toString().padLeft(2, '0');
    final ano = local.year.toString();
    final hora = local.hour.toString().padLeft(2, '0');
    final minuto = local.minute.toString().padLeft(2, '0');
    return '$dia/$mes/$ano às $hora:$minuto';
  }
}
