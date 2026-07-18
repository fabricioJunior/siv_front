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

/// Extrai numero e serie da chave de acesso (44 digitos, padrao SEFAZ):
/// posicoes 22-24 = serie, 25-33 = numero da nota.
({String numero, String serie})? _numeroSerie(String? chaveAcesso) {
  final chave = chaveAcesso?.replaceAll(RegExp(r'\D'), '');
  if (chave == null || chave.length != 44) return null;
  return (
    serie: chave.substring(22, 25).replaceFirst(RegExp(r'^0+(?=\d)'), ''),
    numero: chave.substring(25, 34).replaceFirst(RegExp(r'^0+(?=\d)'), ''),
  );
}

const _formasPagamentoWebmania = {
  '01': 'Dinheiro',
  '02': 'Cheque',
  '03': 'Cartão de Crédito',
  '04': 'Cartão de Débito',
  '05': 'Crédito Loja',
  '10': 'Vale Alimentação',
  '11': 'Vale Refeição',
  '12': 'Vale Presente',
  '13': 'Vale Combustível',
  '15': 'Boleto Bancário',
  '17': 'PIX',
  '90': 'Sem pagamento',
  '99': 'Outros',
};

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
    final destinatario = webmaniaPayload?['destinatario'];

    final valorTotal = pedido is Map && pedido['total'] is num
        ? pedido['total'] as num
        : (documento.payload?['valorLiquido'] as num?) ?? 0;
    final desconto =
        pedido is Map && pedido['desconto'] is num ? pedido['desconto'] as num : 0;
    final valorProdutos = valorTotal + desconto;
    final formaPagamentoCodigo =
        pedido is Map ? pedido['forma_pagamento']?.toString() : null;
    final valorPagamento =
        pedido is Map && pedido['valor_pagamento'] is num ? pedido['valor_pagamento'] as num : null;

    final numeroSerie = _numeroSerie(documento.chaveAcesso);
    final ehNfce = documento.tipoDocumento.toLowerCase().contains('nfce');

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                ehNfce ? 'NFC-e' : 'DANFE - Documento Auxiliar da NF-e',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
              ),
            ),
            if (ehNfce)
              pw.Center(
                child: pw.Text(
                  'Não permite aproveitamento de crédito de ICMS',
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontSize: 7),
                ),
              ),
            pw.SizedBox(height: 4),
            pw.Divider(color: PdfColors.grey700, thickness: 0.5),
            _linha('CÓDIGO / DESCRIÇÃO', destaque: true),
            pw.SizedBox(height: 2),
            for (final produto in produtos) ...[
              _linha(produto.nome),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    '${_fmtQuantidade(produto.quantidade)} UN x ${_fmtMoeda(produto.valorUnitario)}',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                  pw.Text(
                    _fmtMoeda(produto.total),
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ],
              ),
              pw.SizedBox(height: 2),
            ],
            pw.Divider(color: PdfColors.grey700, thickness: 0.5),
            _linhaValor('VALOR TOTAL', valorProdutos),
            if (desconto > 0) _linhaValor('DESCONTO', desconto),
            _linhaValor('VALOR A PAGAR', valorTotal, destaque: true),
            pw.SizedBox(height: 4),
            pw.Divider(color: PdfColors.grey700, thickness: 0.5),
            _linha('FORMA DE PAGAMENTO', destaque: true),
            _linha(_formasPagamentoWebmania[formaPagamentoCodigo] ??
                _naoVazio(formaPagamentoCodigo)),
            if (valorPagamento != null) _linhaValor('VALOR PAGO', valorPagamento),
            pw.SizedBox(height: 4),
            pw.Divider(color: PdfColors.grey700, thickness: 0.5),
            _linha(_naoVazio(documento.pessoaNome, 'CONSUMIDOR NÃO IDENTIFICADO'),
                destaque: true),
            if (destinatario is Map) ...[
              if ((destinatario['cpf'] as String?)?.isNotEmpty == true)
                _linha('CPF: ${destinatario['cpf']}'),
              if ((destinatario['cnpj'] as String?)?.isNotEmpty == true)
                _linha('CNPJ: ${destinatario['cnpj']}'),
            ],
            pw.SizedBox(height: 4),
            pw.Divider(color: PdfColors.grey700, thickness: 0.5),
            if (numeroSerie != null)
              _linha(
                '${ehNfce ? 'NFC-e' : 'NF-e'} nº ${numeroSerie.numero} - Série ${numeroSerie.serie}',
              ),
            _linha('Emissão: ${_fmtDt(documento.updatedAt)}'),
            if (documento.protocolo != null)
              _linha('Protocolo de autorização: ${documento.protocolo}'),
            if (documento.chaveAcesso != null) ...[
              pw.SizedBox(height: 2),
              _linha('Chave de acesso', destaque: true),
              pw.Text(
                documento.chaveAcesso!,
                style: const pw.TextStyle(fontSize: 8),
              ),
            ],
            pw.SizedBox(height: 6),
            if (documento.erroMensagem != null) ...[
              _linha('Obs.: ${documento.erroMensagem}'),
              pw.SizedBox(height: 6),
            ],
            pw.Divider(color: PdfColors.grey700, thickness: 0.5),
            pw.Center(
              child: pw.Text(
                'Documento gerado localmente — DANFE oficial indisponível no momento',
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 6.5),
              ),
            ),
            pw.SizedBox(height: 2),
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

  static pw.Widget _linhaValor(String rotulo, num valor, {bool destaque = false}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 1),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              rotulo,
              style: pw.TextStyle(
                fontSize: destaque ? 10 : 9,
                fontWeight: destaque ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
            pw.Text(
              _fmtMoeda(valor),
              style: pw.TextStyle(
                fontSize: destaque ? 10 : 9,
                fontWeight: destaque ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ],
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
