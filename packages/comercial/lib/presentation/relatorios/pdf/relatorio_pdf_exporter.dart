import 'package:comercial/domain/models/relatorios.dart';
import 'package:core/pdf.dart' show PdfPageFormat, PdfColor, PdfColors, PdfService;
import 'package:core/pdf_widgets.dart' as pw;

String _fmtMoeda(double v) {
  final s = v.toStringAsFixed(2);
  final partes = s.split('.');
  final inteiro = partes[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]}.',
  );
  return 'R\$ $inteiro,${partes[1]}';
}

String _fmtData(String isoDate) {
  if (isoDate.isEmpty) return '-';
  final p = isoDate.split('-');
  if (p.length < 3) return isoDate;
  return '${p[2]}/${p[1]}/${p[0]}';
}

PdfColor get _verde => const PdfColor.fromInt(0xFF2E7D32);
PdfColor get _indigo => const PdfColor.fromInt(0xFF283593);
PdfColor get _roxo => const PdfColor.fromInt(0xFF6A1B9A);
PdfColor get _cinza => const PdfColor.fromInt(0xFF616161);

pw.Widget _cabecalho(String titulo, String periodo, PdfColor cor) =>
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
            'Período: $periodo',
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
                    pw.Text(k.$1,
                        style: const pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.grey700,
                        )),
                    pw.SizedBox(height: 2),
                    pw.Text(k.$2,
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        )),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );

class RelatorioPdfExporter {
  RelatorioPdfExporter._();

  static Future<void> exportarFaturamento(
    RelatorioFaturamento dados,
    String dataInicial,
    String dataFinal,
  ) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => [
          _cabecalho(
            'Relatório de Faturamento e Ticket Médio',
            '${_fmtData(dataInicial)} a ${_fmtData(dataFinal)}',
            _verde,
          ),
          pw.SizedBox(height: 12),
          _kpiRow([
            ('Faturamento total', _fmtMoeda(dados.total)),
            ('Ticket médio', _fmtMoeda(dados.ticketMedio)),
            ('Qtd. vendas', '${dados.quantidadeVendas}'),
            ('Produtos vendidos', '${dados.quantidadeProdutosVendidos}'),
          ]),
          pw.SizedBox(height: 16),
          for (final empresa in dados.empresas) ...[
            pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 4),
              padding: const pw.EdgeInsets.symmetric(
                  horizontal: 10, vertical: 6),
              decoration: pw.BoxDecoration(color: PdfColors.green50),
              child: pw.Text(
                empresa.empresaNome,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
            _kpiRow([
              ('Fat. empresa', _fmtMoeda(empresa.total)),
              ('Ticket médio', _fmtMoeda(empresa.ticketMedio)),
              ('Vendas', '${empresa.quantidadeVendas}'),
              ('Produtos', '${empresa.quantidadeProdutosVendidos}'),
            ]),
            if (empresa.vendedores.isNotEmpty) ...[
              pw.SizedBox(height: 8),
              pw.Text('Vendedores',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 9,
                    color: _cinza,
                  )),
              pw.SizedBox(height: 4),
              pw.Table(
                border: pw.TableBorder.all(
                    color: PdfColors.grey300, width: 0.5),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(1),
                  3: const pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey100),
                    children: ['Vendedor', 'Fat.', 'Vendas', 'Ticket']
                        .map(
                          (h) => pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(h,
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 8)),
                          ),
                        )
                        .toList(),
                  ),
                  for (final v in empresa.vendedores)
                    pw.TableRow(
                      children: [
                        v.funcionarioNome,
                        _fmtMoeda(v.total),
                        '${v.quantidadeVendas}',
                        _fmtMoeda(v.ticketMedio),
                      ]
                          .map(
                            (c) => pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(c,
                                  style: const pw.TextStyle(fontSize: 8)),
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            ],
            pw.SizedBox(height: 12),
          ],
        ],
      ),
    );
    await PdfService.compartilhar(
      await doc.save(),
      'faturamento_${dataInicial}_${dataFinal}.pdf',
    );
  }

  static Future<void> exportarCurvaAbc(
    RelatorioCurvaAbc dados,
    String dataInicial,
    String dataFinal,
  ) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (ctx) => [
          _cabecalho(
            'Relatório — Curva ABC de Produtos',
            '${_fmtData(dataInicial)} a ${_fmtData(dataFinal)}',
            _indigo,
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Total de produtos: ${dados.meta.totalItems}  |  '
            'Página ${dados.meta.currentPage}/${dados.meta.totalPages}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(
                color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(1),
              3: const pw.FlexColumnWidth(2),
              4: const pw.FlexColumnWidth(1),
              5: const pw.FlexColumnWidth(1),
              6: const pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                decoration:
                    const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  'Referência',
                  'Cor',
                  'Tam.',
                  'Valor vendido',
                  'Qtd.',
                  '% Part.',
                  'Classe'
                ]
                    .map(
                      (h) => pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(h,
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8)),
                      ),
                    )
                    .toList(),
              ),
              for (final item in dados.items)
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: item.classeAbc == 'A'
                        ? PdfColors.green50
                        : item.classeAbc == 'B'
                            ? PdfColors.amber50
                            : PdfColors.red50,
                  ),
                  children: [
                    item.referenciaNome,
                    item.corNome,
                    item.tamanhoNome,
                    _fmtMoeda(item.valorTotalVendido),
                    '${item.quantidadeVendida}',
                    '${item.percentualParticipacao.toStringAsFixed(2)}%',
                    item.classeAbc,
                  ]
                      .map(
                        (c) => pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child:
                              pw.Text(c, style: const pw.TextStyle(fontSize: 8)),
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
      'curva_abc_${dataInicial}_${dataFinal}.pdf',
    );
  }

  static Future<void> exportarClientesAtivos(
    RelatorioClientesAtivos dados,
    int dias,
    String? dataReferencia,
  ) async {
    final doc = pw.Document();
    final ref = dataReferencia != null ? _fmtData(dataReferencia) : 'hoje';
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => [
          _cabecalho(
            'Relatório — Clientes Ativos',
            'Últimos $dias dias até $ref',
            _roxo,
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Total de clientes: ${dados.meta.totalItems}  |  '
            'Página ${dados.meta.currentPage}/${dados.meta.totalPages}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(
                color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(1),
              3: const pw.FlexColumnWidth(2),
              4: const pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                decoration:
                    const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  'Cliente',
                  'Empresa',
                  'Última compra',
                  'Total comprado',
                  'Qtd.',
                ]
                    .map(
                      (h) => pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(h,
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8)),
                      ),
                    )
                    .toList(),
              ),
              for (final item in dados.items)
                pw.TableRow(
                  children: [
                    item.clienteNome,
                    item.empresaNome,
                    _fmtData(item.dataUltimaCompra),
                    _fmtMoeda(item.valorTotalComprado),
                    '${item.quantidadeCompras}',
                  ]
                      .map(
                        (c) => pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(c,
                              style: const pw.TextStyle(fontSize: 8)),
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
      'clientes_ativos_${dias}d.pdf',
    );
  }
}
