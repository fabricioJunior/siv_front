import 'package:core/pdf.dart' show PdfPageFormat, PdfColors, PdfService;
import 'package:core/pdf_widgets.dart' as pw;
import 'package:financeiro/domain/models/contagem_do_caixa_item.dart';
import 'package:financeiro/domain/models/recibo_fechamento_caixa.dart';

String _fmtMoeda(double? v) {
  final s = (v ?? 0).toStringAsFixed(2);
  final partes = s.split('.');
  final inteiro = partes[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]}.',
  );
  return 'R\$ $inteiro,${partes[1]}';
}

String _fmtData(DateTime? data) {
  if (data == null) return '-';
  final local = data.toLocal();
  final dia = local.day.toString().padLeft(2, '0');
  final mes = local.month.toString().padLeft(2, '0');
  final ano = local.year.toString();
  return '$dia/$mes/$ano';
}

String _fmtDataHora(DateTime? data) {
  if (data == null) return '-';
  final local = data.toLocal();
  final hora = local.hour.toString().padLeft(2, '0');
  final minuto = local.minute.toString().padLeft(2, '0');
  return '${_fmtData(local)} $hora:$minuto';
}

String _naoVazio(String? v, [String fallback = '-']) =>
    (v?.trim().isNotEmpty ?? false) ? v!.trim() : fallback;

String _labelTipoDocumento(TipoContagemDoCaixaItem tipo) {
  switch (tipo) {
    case TipoContagemDoCaixaItem.dinheiro:
      return 'Dinheiro';
    case TipoContagemDoCaixaItem.pix:
      return 'Pix';
    case TipoContagemDoCaixaItem.cartao:
      return 'Cartão';
    case TipoContagemDoCaixaItem.fatura:
      return 'Fatura';
    case TipoContagemDoCaixaItem.cheque:
      return 'Cheque';
    case TipoContagemDoCaixaItem.troco:
      return 'Troco';
    case TipoContagemDoCaixaItem.voucher:
      return 'Voucher';
    case TipoContagemDoCaixaItem.tedDoc:
      return 'TED/DOC';
    case TipoContagemDoCaixaItem.adiantamento:
      return 'Adiantamento';
    case TipoContagemDoCaixaItem.creditoDeDevolucao:
      return 'Crédito de devolução';
  }
}

pw.Widget _tabelaMovimentacao(
  List<MovimentacaoRecibo> itens,
  String vazioLabel,
) {
  return pw.Table(
    border: _bordaFina,
    columnWidths: const {
      0: pw.FlexColumnWidth(1),
      1: pw.FlexColumnWidth(1.5),
      2: pw.FlexColumnWidth(2),
      3: pw.FlexColumnWidth(1.5),
      4: pw.FlexColumnWidth(1),
    },
    children: [
      _linhaCabecalhoTabela(
        ['Valor', 'Data/Hora', 'Descrição', 'Operador', 'Situação'],
      ),
      if (itens.isEmpty)
        _linhaDadosTabela(['-', '-', vazioLabel, '-', '-'])
      else
        for (final item in itens)
          _linhaDadosTabela([
            _fmtMoeda(item.valor),
            _fmtDataHora(item.dataHora),
            _naoVazio(item.descricao, item.origem),
            _naoVazio(item.operadorNome, '${item.operadorId}'),
            item.cancelado
                ? 'Cancelada${item.motivoCancelamento?.trim().isNotEmpty == true ? ': ${item.motivoCancelamento}' : ''}'
                : 'Ativa',
          ]),
    ],
  );
}

final _bordaFina = pw.TableBorder.all(color: PdfColors.grey600, width: 0.5);

pw.Widget _titulo() => pw.Center(
      child: pw.Text(
        'Recibo de fechamento de caixa',
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

pw.Widget _tabelaFaturamento(String titulo, FaturamentoResumoRecibo dados) {
  return pw.Table(
    border: _bordaFina,
    columnWidths: const {
      0: pw.FlexColumnWidth(1.5),
      1: pw.FlexColumnWidth(1),
      2: pw.FlexColumnWidth(1.5),
      3: pw.FlexColumnWidth(1),
    },
    children: [
      _linhaCabecalhoTabela(['Total', 'Qtd. vendas', 'Qtd. produtos', 'Ticket médio']),
      _linhaDadosTabela([
        _fmtMoeda(dados.total),
        '${dados.quantidadeVendas}',
        '${dados.quantidadeProdutosVendidos}',
        _fmtMoeda(dados.ticketMedio),
      ]),
    ],
  );
}

class ReciboFechamentoCaixaPdfExporter {
  ReciboFechamentoCaixaPdfExporter._();

  static Future<void> exportar(ReciboFechamentoCaixa recibo) async {
    final doc = pw.Document();

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
                    _linha('Caixa: ${recibo.caixaId}   Terminal: ${recibo.terminalId}'),
                    _linha('Empresa: ${recibo.empresaId}'),
                    _linha('Data: ${_fmtData(recibo.data)}'),
                    _linha(
                      'Operador abertura: ${recibo.operadorAberturaId} - ${_naoVazio(recibo.operadorAberturaNome)}',
                    ),
                    _linha(
                      'Operador fechamento: ${recibo.operadorFechamentoId ?? '-'} - ${_naoVazio(recibo.operadorFechamentoNome)}',
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
                    _linha('Abertura: ${_fmtDataHora(recibo.abertura)}'),
                    _linha('Fechamento: ${_fmtDataHora(recibo.fechamento)}'),
                    _linha('Valor abertura: ${_fmtMoeda(recibo.valorAbertura)}'),
                    _linha(
                      'Valor fechamento: ${_fmtMoeda(recibo.valorFechamento)}',
                      destaque: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Divider(color: PdfColors.grey700, thickness: 0.7),
          _tituloSecao('Faturamento do caixa'),
          _tabelaFaturamento('Faturamento do caixa', recibo.faturamentoCaixa),
          _tituloSecao('Faturamento do dia'),
          _tabelaFaturamento('Faturamento do dia', recibo.faturamentoDia),
          _tituloSecao('Faturamento do mês (até o fechamento)'),
          pw.Text(
            _fmtMoeda(recibo.faturamentoMes.total),
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
          _tituloSecao('Valores contados'),
          pw.Table(
            border: _bordaFina,
            columnWidths: const {
              0: pw.FlexColumnWidth(2),
              1: pw.FlexColumnWidth(1),
            },
            children: [
              _linhaCabecalhoTabela(['Forma de pagamento', 'Valor']),
              if (recibo.valoresContados.isEmpty)
                _linhaDadosTabela(['Nenhum valor contado', '-'])
              else
                for (final item in recibo.valoresContados)
                  _linhaDadosTabela([
                    _labelTipoDocumento(item.tipoDocumento),
                    _fmtMoeda(item.valor),
                  ]),
            ],
          ),
          _tituloSecao('Sangrias'),
          _tabelaMovimentacao(recibo.sangrias, 'Nenhuma sangria'),
          _tituloSecao('Suprimentos'),
          _tabelaMovimentacao(recibo.suprimentos, 'Nenhum suprimento'),
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
      'recibo_fechamento_caixa_${recibo.caixaId}.pdf',
    );
  }
}
