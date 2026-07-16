import 'package:core/pdf.dart' show PdfPageFormat, PdfColor, PdfColors, PdfService;
import 'package:core/pdf_widgets.dart' as pw;
import 'package:estoque/domain/models/preco_referencia_estoque.dart';
import 'package:estoque/domain/models/produto_do_estoque.dart';

String _fmtMoeda(double v) {
  final s = v.toStringAsFixed(2);
  final partes = s.split('.');
  final inteiro = partes[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]}.',
  );
  return 'R\$ $inteiro,${partes[1]}';
}

String _fmtData(DateTime? value) {
  if (value == null) return '-';
  final d = value.day.toString().padLeft(2, '0');
  final m = value.month.toString().padLeft(2, '0');
  final y = value.year.toString();
  return '$d/$m/$y';
}

PdfColor get _azul => const PdfColor.fromInt(0xFF1565C0);

pw.Widget _cabecalho(String titulo, String subtitulo, PdfColor cor) =>
    pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(color: cor),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            titulo,
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            subtitulo,
            style: const pw.TextStyle(color: PdfColors.white, fontSize: 10),
          ),
        ],
      ),
    );

pw.Widget _kpiRow(List<(String, String)> kpis) => pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
      children: kpis
          .map(
            (k) => pw.Expanded(
              child: pw.Container(
                margin: const pw.EdgeInsets.all(4),
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(6),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      k.$1,
                      style: const pw.TextStyle(
                        fontSize: 8,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      k.$2,
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );

class EstoqueRelatorioPdfExporter {
  EstoqueRelatorioPdfExporter._();

  static Future<void> exportarValorEstoque({
    required List<ProdutoDoEstoque> itens,
    required List<PrecoReferenciaEstoque> precos,
    required String tabelaDePrecoNome,
  }) async {
    final precoPorReferencia = <int, double>{
      for (final p in precos) p.referenciaId: p.valor,
    };

    var valorTotal = 0.0;
    var itensSemPreco = 0;
    for (final item in itens) {
      final valorUnitario = precoPorReferencia[item.referenciaId];
      if (valorUnitario == null) {
        itensSemPreco++;
        continue;
      }
      valorTotal += valorUnitario * item.saldo;
    }

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        maxPages: 1000,
        build: (ctx) => [
          _cabecalho(
            'Relatório — Valor Total do Estoque',
            'Tabela de preço: $tabelaDePrecoNome  |  Gerado em: ${_fmtData(DateTime.now())}',
            _azul,
          ),
          pw.SizedBox(height: 12),
          _kpiRow([
            ('Valor total do estoque', _fmtMoeda(valorTotal)),
            ('Itens no relatório', '${itens.length}'),
            ('Itens sem preço na tabela', '$itensSemPreco'),
          ]),
          pw.SizedBox(height: 16),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(1),
              4: const pw.FlexColumnWidth(1),
              5: const pw.FlexColumnWidth(2),
              6: const pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  'Referência',
                  'Produto',
                  'Cor',
                  'Tam.',
                  'Saldo',
                  'Valor unit.',
                  'Valor total',
                ]
                    .map(
                      (h) => pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          h,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 8,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              for (final item in itens)
                pw.TableRow(
                  decoration: precoPorReferencia[item.referenciaId] == null
                      ? const pw.BoxDecoration(color: PdfColors.red50)
                      : null,
                  children: [
                    item.referenciaIdExterno ?? '${item.referenciaId}',
                    item.nome,
                    item.corNome,
                    item.tamanhoNome,
                    item.saldo.round().toString(),
                    precoPorReferencia[item.referenciaId] == null
                        ? '-'
                        : _fmtMoeda(precoPorReferencia[item.referenciaId]!),
                    precoPorReferencia[item.referenciaId] == null
                        ? '-'
                        : _fmtMoeda(
                            precoPorReferencia[item.referenciaId]! *
                                item.saldo,
                          ),
                  ]
                      .map(
                        (c) => pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            c,
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        ],
      ),
    );

    await PdfService.compartilhar(
      await doc.save(),
      'valor_estoque_${tabelaDePrecoNome.replaceAll(RegExp(r'\s+'), '_').toLowerCase()}.pdf',
    );
  }
}
