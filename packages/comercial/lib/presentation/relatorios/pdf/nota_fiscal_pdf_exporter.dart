import 'dart:typed_data';

import 'package:comercial/domain/models/documento_fiscal.dart';
import 'package:comercial/domain/models/documento_fiscal_extensoes.dart';
import 'package:core/pdf.dart' show PdfPageFormat, PdfColors, PdfService;
import 'package:core/pdf_widgets.dart' as pw;

String _fmtMoeda(num? v) {
  final s = (v ?? 0).toStringAsFixed(2);
  final partes = s.split('.');
  final inteiro = partes[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]}.',
  );
  return 'R\$ $inteiro,${partes[1]}';
}

String _fmtQuantidade(num? v) {
  if (v == null) return '-';
  if (v == v.truncateToDouble()) return v.toInt().toString();
  return v.toStringAsFixed(2).replaceAll('.', ',');
}

String _fmtDt(DateTime? dt) {
  if (dt == null) return '-';
  final local = dt.toLocal();
  return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year} '
      '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
}

String _naoVazio(String? v, [String fallback = '-']) =>
    (v?.trim().isNotEmpty ?? false) ? v!.trim() : fallback;

/// Gera/obtem o PDF da nota fiscal (DANFE) para impressao em impressora
/// termica 80mm.
///
/// Estrategia: tenta baixar a DANFE ja pronta a partir de
/// [DocumentoFiscal.urlDanfe] (gerada pelo gateway fiscal, ex: Web Mania).
/// Se a URL nao existir ou o download falhar (rede, formato invalido etc),
/// monta um layout proprio simplificado (fallback), no estilo do romaneio.
class NotaFiscalPdfExporter {
  NotaFiscalPdfExporter._();

  static Future<Uint8List> gerarBytes(DocumentoFiscal documento) async {
    final url = documento.urlDanfe;
    if (url != null) {
      final baixado = await PdfService.baixarPdf(url);
      if (baixado != null) return baixado;
    }

    return _gerarFallback(documento);
  }

  static Future<Uint8List> _gerarFallback(DocumentoFiscal documento) async {
    final doc = pw.Document();
    final webmaniaPayload = _webmaniaPayload(documento);
    final produtos = _produtos(webmaniaPayload);
    final pedido = webmaniaPayload?['pedido'];
    final valorTotal = pedido is Map && pedido['total'] is num
        ? pedido['total'] as num
        : (documento.payload?['valorLiquido'] as num?) ?? 0;
    final destinatario = webmaniaPayload?['destinatario'];

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                'DANFE - Documento Auxiliar da NF-e',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Divider(color: PdfColors.grey700, thickness: 0.5),
            _linha('Nota: #${documento.id}', destaque: true),
            _linha('Status: ${documento.status.replaceAll('_', ' ')}'),
            if (documento.chaveAcesso != null)
              _linha('Chave: ${documento.chaveAcesso}'),
            if (documento.protocolo != null)
              _linha('Protocolo: ${documento.protocolo}'),
            _linha('Emitida em: ${_fmtDt(documento.updatedAt)}'),
            pw.SizedBox(height: 4),
            pw.Divider(color: PdfColors.grey700, thickness: 0.5),
            _linha('Destinatário: ${_naoVazio(documento.pessoaNome)}', destaque: true),
            if (destinatario is Map) ...[
              if ((destinatario['cpf'] as String?)?.isNotEmpty == true)
                _linha('CPF: ${destinatario['cpf']}'),
              if ((destinatario['cnpj'] as String?)?.isNotEmpty == true)
                _linha('CNPJ: ${destinatario['cnpj']}'),
            ],
            pw.SizedBox(height: 4),
            pw.Divider(color: PdfColors.grey700, thickness: 0.5),
            _linha('Produtos', destaque: true),
            pw.SizedBox(height: 2),
            for (final produto in produtos) ...[
              _linha(produto.nome),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 4, bottom: 2),
                child: pw.Text(
                  '${_fmtQuantidade(produto.quantidade)} x ${_fmtMoeda(produto.valorUnitario)} = ${_fmtMoeda(produto.total)}',
                  style: const pw.TextStyle(fontSize: 8),
                ),
              ),
            ],
            pw.Divider(color: PdfColors.grey700, thickness: 0.5),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Total: ${_fmtMoeda(valorTotal)}',
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 10),
            if (documento.erroMensagem != null) ...[
              _linha('Obs.: ${documento.erroMensagem}'),
              pw.SizedBox(height: 6),
            ],
            pw.Center(
              child: pw.Text(
                'Romaneio #${documento.romaneioId}',
                style: const pw.TextStyle(fontSize: 8),
              ),
            ),
          ],
        ),
      ),
    );

    return doc.save();
  }

  static pw.Widget _linha(String texto, {bool destaque = false}) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 1),
        child: pw.Text(
          texto,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: destaque ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      );

  static Map<String, dynamic>? _webmaniaPayload(DocumentoFiscal documento) {
    final wm = documento.payload?['webmania'];
    if (wm is! Map<String, dynamic>) return null;
    final p = wm['payload'];
    return p is Map<String, dynamic> ? p : null;
  }

  static List<({String nome, num quantidade, num valorUnitario, num total})>
      _produtos(Map<String, dynamic>? webmaniaPayload) {
    final produtos = webmaniaPayload?['produtos'];
    if (produtos is! List) return const [];
    return produtos.whereType<Map>().map((p) {
      final quantidade = (p['quantidade'] as num?) ?? 0;
      final total = (p['total'] as num?) ?? (p['subtotal'] as num?) ?? 0;
      final valorUnitario = (p['valor'] as num?) ??
          (quantidade > 0 ? total / quantidade : total);
      return (
        nome: (p['nome'] as String?) ?? '-',
        quantidade: quantidade,
        valorUnitario: valorUnitario,
        total: total,
      );
    }).toList();
  }
}
