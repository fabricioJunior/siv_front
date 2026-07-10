import 'package:comercial/domain/models/romaneio.dart';
import 'package:comercial/domain/models/romaneio_item.dart';
import 'package:comercial/domain/models/romaneio_item_devolvido.dart';
import 'package:core/pdf.dart' show PdfPageFormat, PdfColors, PdfService;
import 'package:core/pdf_widgets.dart' as pw;

String _fmtMoeda(double? v) {
  final s = (v ?? 0).toStringAsFixed(2);
  final partes = s.split('.');
  final inteiro = partes[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]}.',
  );
  return 'R\$ $inteiro,${partes[1]}';
}

String _fmtQuantidade(double? v) {
  if (v == null) return '-';
  if (v == v.truncateToDouble()) return v.toInt().toString();
  return v.toStringAsFixed(2).replaceAll('.', ',');
}

String _fmtData(DateTime? data) {
  if (data == null) return '-';
  final local = data.toLocal();
  final dia = local.day.toString().padLeft(2, '0');
  final mes = local.month.toString().padLeft(2, '0');
  final ano = local.year.toString();
  return '$dia/$mes/$ano';
}

String _fmtDataString(String? valor) {
  if (valor == null || valor.trim().isEmpty) return '-';
  final data = DateTime.tryParse(valor);
  return data == null ? valor : _fmtData(data);
}

String _naoVazio(String? v, [String fallback = '-']) =>
    (v?.trim().isNotEmpty ?? false) ? v!.trim() : fallback;

final _bordaFina = pw.TableBorder.all(color: PdfColors.grey600, width: 0.5);

pw.Widget _titulo() => pw.Center(
      child: pw.Text(
        'Romaneio',
        style: pw.TextStyle(
          fontSize: 18,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.black,
        ),
      ),
    );

pw.Widget _linha(String texto, {bool destaque = false}) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Text(
        texto,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: destaque ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );

pw.Widget _tituloSecao(String titulo) => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 10, bottom: 4),
      child: pw.Text(
        titulo,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
      ),
    );

pw.TableRow _linhaCabecalhoTabela(List<String> colunas) => pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
      children: colunas
          .map(
            (h) => pw.Padding(
              padding: const pw.EdgeInsets.all(3),
              child: pw.Text(
                h,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
              ),
            ),
          )
          .toList(),
    );

pw.TableRow _linhaDadosTabela(List<String> colunas) => pw.TableRow(
      children: colunas
          .map(
            (c) => pw.Padding(
              padding: const pw.EdgeInsets.all(3),
              child: pw.Text(c, style: const pw.TextStyle(fontSize: 8)),
            ),
          )
          .toList(),
    );

const _colunasProdutos = <int, pw.TableColumnWidth>{
  0: pw.FlexColumnWidth(1.5),
  1: pw.FlexColumnWidth(2),
  2: pw.FlexColumnWidth(3.5),
  3: pw.FlexColumnWidth(1.5),
  4: pw.FlexColumnWidth(1),
  5: pw.FlexColumnWidth(1),
  6: pw.FlexColumnWidth(1.5),
  7: pw.FlexColumnWidth(1.5),
  8: pw.FlexColumnWidth(1.5),
};

const _cabecalhoProdutos = [
  'Produto',
  'Referência',
  'Descrição',
  'Cor',
  'Tam',
  'Qtd',
  'Vl.Unit',
  'Desconto',
  'Total',
];

class RomaneioPdfExporter {
  RomaneioPdfExporter._();

  static Future<void> exportar(
    Romaneio romaneio,
    List<RomaneioItem> itens,
    List<RomaneioItemDevolvido> itensDevolvidos,
  ) async {
    final doc = pw.Document();
    final itensAtivos =
        itens.where((item) => (item.quantidade ?? 0) != 0).toList();

    final quantidadeTotal = itensAtivos.fold<double>(
      0,
      (acumulado, item) => acumulado + (item.quantidade ?? 0),
    );
    final valorTotal = itensAtivos.fold<double>(
      0,
      (acumulado, item) =>
          acumulado + (item.valorTotalLiquido ?? item.valorTotalBruto ?? 0),
    );

    final pagamentos = romaneio.formasDePagamentoRealizadas;
    final totalPago = pagamentos.fold<double>(
      0,
      (acumulado, pagamento) => acumulado + pagamento.valor,
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => [
          _titulo(),
          pw.SizedBox(height: 10),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 3,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _linha('Empresa: ${_naoVazio(romaneio.empresaNome)}'),
                    _linha(
                      'Loja: ${_naoVazio(romaneio.empresaNomeFantasia ?? romaneio.empresaNome)}',
                    ),
                    pw.RichText(
                      text: pw.TextSpan(
                        style: const pw.TextStyle(fontSize: 9),
                        children: [
                          const pw.TextSpan(text: 'Romaneio: '),
                          pw.TextSpan(
                            text: '${romaneio.id ?? '-'}',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    _linha(
                      'Pessoa: ${romaneio.pessoaId ?? '-'} - ${_naoVazio(romaneio.pessoaNome)}',
                    ),
                    if (romaneio.temEntrega == true) ...[
                      _linha(
                        'Endereço: ${_naoVazio(romaneio.enderecoLogradouro, '')}, ${_naoVazio(romaneio.enderecoNumero, '')}   Bairro: ${_naoVazio(romaneio.enderecoBairro)}',
                      ),
                      _linha(
                        'Cidade: ${_naoVazio(romaneio.enderecoMunicipio, '')}-${_naoVazio(romaneio.enderecoUf, '')}  CEP: ${_naoVazio(romaneio.enderecoCep)}',
                      ),
                    ],
                    _linha(
                      'CPF/CNPJ: ${_naoVazio(romaneio.pessoaDocumento)}   Telefone: ${_naoVazio(romaneio.pessoaContato)}',
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                flex: 2,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _linha('Data da venda: ${_fmtData(romaneio.data)}'),
                    _linha(
                      'Caixa: ${_naoVazio(romaneio.caixaTerminalNome ?? romaneio.operadorNome)}',
                    ),
                    _linha(
                      'Vendedor: ${romaneio.funcionarioId ?? '-'} - ${_naoVazio(romaneio.funcionarioNome)}',
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Divider(color: PdfColors.grey700, thickness: 0.7),
          _tituloSecao('Produtos'),
          pw.Table(
            border: _bordaFina,
            columnWidths: _colunasProdutos,
            children: [
              _linhaCabecalhoTabela(_cabecalhoProdutos),
              for (final item in itensAtivos)
                _linhaDadosTabela([
                  '${item.produtoId ?? '-'}',
                  _naoVazio(item.referenciaNome),
                  _naoVazio(item.referenciaDescricao),
                  _naoVazio(item.corNome),
                  _naoVazio(item.tamanhoNome),
                  _fmtQuantidade(item.quantidade),
                  _fmtMoeda(item.valorUnitario),
                  _fmtMoeda(item.valorTotalDesconto),
                  _fmtMoeda(item.valorTotalLiquido ?? item.valorTotalBruto),
                ]),
            ],
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 4),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                  'Qtd: ${_fmtQuantidade(quantidadeTotal)}   Total: ${_fmtMoeda(valorTotal)}',
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
          ),
          _tituloSecao('Peças devolvidas'),
          pw.Table(
            border: _bordaFina,
            columnWidths: _colunasProdutos,
            children: [
              _linhaCabecalhoTabela(_cabecalhoProdutos),
              for (final item in itensDevolvidos)
                _linhaDadosTabela([
                  '${item.produtoId ?? '-'}',
                  _naoVazio(item.referenciaNome),
                  _naoVazio(item.referenciaDescricao),
                  _naoVazio(item.corNome),
                  _naoVazio(item.tamanhoNome),
                  _fmtQuantidade(item.quantidade),
                  item.valorUnitario == null ? '-' : _fmtMoeda(item.valorUnitario),
                  item.valorTotalDesconto == null
                      ? '-'
                      : _fmtMoeda(item.valorTotalDesconto),
                  item.valorTotalLiquido == null
                      ? '-'
                      : _fmtMoeda(item.valorTotalLiquido),
                ]),
            ],
          ),
          _tituloSecao('Observações:'),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(6),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey500, width: 0.5),
            ),
            child: pw.Text(
              _naoVazio(romaneio.observacao, ''),
              style: const pw.TextStyle(fontSize: 9),
            ),
          ),
          _tituloSecao('Entrega'),
          pw.Table(
            border: _bordaFina,
            columnWidths: const {
              0: pw.FlexColumnWidth(1),
              1: pw.FlexColumnWidth(2),
            },
            children: [
              _linhaCabecalhoTabela(['Taxa', 'Prazo']),
              _linhaDadosTabela([
                romaneio.valorFrete == null
                    ? '-'
                    : _fmtMoeda(romaneio.valorFrete),
                romaneio.prazoFrete != null
                    ? '${romaneio.prazoFrete} dia(s)'
                    : _naoVazio(romaneio.observacaoFrete),
              ]),
            ],
          ),
          _tituloSecao('Pagamento'),
          pw.Table(
            border: _bordaFina,
            columnWidths: const {
              0: pw.FlexColumnWidth(1.5),
              1: pw.FlexColumnWidth(2.5),
              2: pw.FlexColumnWidth(1),
              3: pw.FlexColumnWidth(1.5),
              4: pw.FlexColumnWidth(1.5),
            },
            children: [
              _linhaCabecalhoTabela(
                ['TIPO', 'Forma de pagamento', 'Parcela', 'Valor', 'Vencimento'],
              ),
              for (final pagamento in pagamentos)
                _linhaDadosTabela([
                  _naoVazio(pagamento.tipoHistorico),
                  _naoVazio(pagamento.descricao),
                  '${pagamento.parcela}',
                  _fmtMoeda(pagamento.valor),
                  _fmtDataString(pagamento.vencimento),
                ]),
            ],
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 4),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                  'Total: ${_fmtMoeda(totalPago)}',
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 30),
          pw.Divider(color: PdfColors.grey700, thickness: 0.7),
          pw.Center(
            child: pw.Text('Assinatura', style: const pw.TextStyle(fontSize: 9)),
          ),
        ],
      ),
    );

    await PdfService.compartilhar(
      await doc.save(),
      'romaneio_${romaneio.id ?? ''}.pdf',
    );
  }
}
