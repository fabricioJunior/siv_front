import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:financeiro/models.dart';
import 'package:financeiro/presentation.dart';
import 'package:financeiro/presentation/relatorios/pdf/recibo_fechamento_caixa_pdf_exporter.dart';
import 'package:flutter/material.dart';

class ReciboFechamentoCaixaPage extends StatefulWidget {
  final int caixaId;

  const ReciboFechamentoCaixaPage({super.key, required this.caixaId});

  @override
  State<ReciboFechamentoCaixaPage> createState() =>
      _ReciboFechamentoCaixaPageState();
}

class _ReciboFechamentoCaixaPageState extends State<ReciboFechamentoCaixaPage> {
  bool _exportandoPdf = false;

  Future<void> _exportarPdf(ReciboFechamentoCaixa recibo) async {
    setState(() => _exportandoPdf = true);
    await ReciboFechamentoCaixaPdfExporter.exportar(recibo);
    if (mounted) {
      setState(() => _exportandoPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReciboFechamentoCaixaBloc>(
      create: (_) => sl<ReciboFechamentoCaixaBloc>()
        ..add(ReciboFechamentoCaixaIniciou(caixaId: widget.caixaId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Recibo do caixa'),
          actions: [
            BlocBuilder<ReciboFechamentoCaixaBloc, ReciboFechamentoCaixaState>(
              builder: (context, state) {
                if (state.recibo == null) return const SizedBox.shrink();
                if (_exportandoPdf) {
                  return const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                return IconButton(
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  tooltip: 'Gerar PDF',
                  onPressed: () => _exportarPdf(state.recibo!),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<ReciboFechamentoCaixaBloc, ReciboFechamentoCaixaState>(
          builder: (context, state) {
            if (state.step == ReciboFechamentoCaixaStep.carregando) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.step == ReciboFechamentoCaixaStep.falha ||
                state.recibo == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 36),
                      const SizedBox(height: 12),
                      Text(
                        state.erro ?? 'Falha ao carregar o recibo do caixa.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () {
                          context.read<ReciboFechamentoCaixaBloc>().add(
                                ReciboFechamentoCaixaIniciou(
                                  caixaId: widget.caixaId,
                                ),
                              );
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final recibo = state.recibo!;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _CardResumoCaixa(recibo: recibo),
                const SizedBox(height: 12),
                _CardFaturamento(
                  titulo: 'Faturamento do caixa',
                  dados: recibo.faturamentoCaixa,
                  mostrarQuantidadeProdutos: true,
                ),
                const SizedBox(height: 8),
                _CardFaturamento(
                  titulo: 'Faturamento do dia',
                  dados: recibo.faturamentoDia,
                ),
                const SizedBox(height: 8),
                _CardFaturamentoMes(faturamentoMes: recibo.faturamentoMes),
                const SizedBox(height: 12),
                _CardValoresContados(valoresContados: recibo.valoresContados),
                const SizedBox(height: 12),
                _CardSangrias(sangrias: recibo.sangrias),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _exportandoPdf ? null : () => _exportarPdf(recibo),
                    icon: _exportandoPdf
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.picture_as_pdf_outlined),
                    label: const Text('Gerar PDF'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CardResumoCaixa extends StatelessWidget {
  final ReciboFechamentoCaixa recibo;

  const _CardResumoCaixa({required this.recibo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Caixa #${recibo.caixaId} — Terminal ${recibo.terminalId}',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text('Data: ${_fmtData(recibo.data)}'),
            Text('Abertura: ${_fmtDataHora(recibo.abertura)}'),
            Text('Fechamento: ${_fmtDataHora(recibo.fechamento)}'),
            const SizedBox(height: 6),
            Text('Operador de abertura: ${recibo.operadorAberturaNome ?? '-'}'),
            Text(
              'Operador de fechamento: ${recibo.operadorFechamentoNome ?? '-'}',
            ),
            const SizedBox(height: 6),
            Text('Valor de abertura: ${_fmtMoeda(recibo.valorAbertura)}'),
            Text(
              'Valor de fechamento: ${_fmtMoeda(recibo.valorFechamento)}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardFaturamento extends StatelessWidget {
  final String titulo;
  final FaturamentoResumoRecibo dados;
  final bool mostrarQuantidadeProdutos;

  const _CardFaturamento({
    required this.titulo,
    required this.dados,
    this.mostrarQuantidadeProdutos = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text('Total: ${_fmtMoeda(dados.total)}'),
            Text('Quantidade de vendas: ${dados.quantidadeVendas}'),
            if (mostrarQuantidadeProdutos)
              Text(
                'Quantidade de produtos vendidos: ${dados.quantidadeProdutosVendidos}',
              ),
            Text('Ticket médio: ${_fmtMoeda(dados.ticketMedio)}'),
          ],
        ),
      ),
    );
  }
}

class _CardFaturamentoMes extends StatelessWidget {
  final FaturamentoMesRecibo faturamentoMes;

  const _CardFaturamentoMes({required this.faturamentoMes});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Faturamento do mês',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text('Total: ${_fmtMoeda(faturamentoMes.total)}'),
          ],
        ),
      ),
    );
  }
}

class _CardValoresContados extends StatelessWidget {
  final List<ValorContadoRecibo> valoresContados;

  const _CardValoresContados({required this.valoresContados});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Valores contados',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            if (valoresContados.isEmpty)
              const Text('Nenhum valor contado neste caixa.')
            else
              ...valoresContados.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_labelTipoDocumento(item.tipoDocumento)),
                      Text(
                        _fmtMoeda(item.valor),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CardSangrias extends StatelessWidget {
  final List<SangriaRecibo> sangrias;

  const _CardSangrias({required this.sangrias});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sangrias',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            if (sangrias.isEmpty)
              const Text('Nenhuma sangria registrada neste caixa.')
            else
              ...sangrias.map((sangria) => _ItemSangria(sangria: sangria)),
          ],
        ),
      ),
    );
  }
}

class _ItemSangria extends StatelessWidget {
  final SangriaRecibo sangria;

  const _ItemSangria({required this.sangria});

  @override
  Widget build(BuildContext context) {
    final cancelada = sangria.cancelado;
    return Opacity(
      opacity: cancelada ? 0.5 : 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sangria.descricao?.trim().isNotEmpty == true
                        ? sangria.descricao!.trim()
                        : sangria.origem,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      decoration:
                          cancelada ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  Text(
                    '${_fmtDataHora(sangria.dataHora)} · ${sangria.operadorNome ?? 'Operador ${sangria.operadorId}'}',
                    style: theme(context).textTheme.bodySmall,
                  ),
                  if (cancelada)
                    Text(
                      'Cancelada${sangria.motivoCancelamento?.trim().isNotEmpty == true ? ': ${sangria.motivoCancelamento}' : ''}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              _fmtMoeda(sangria.valor),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                decoration: cancelada ? TextDecoration.lineThrough : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ThemeData theme(BuildContext context) => Theme.of(context);
}

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

String _fmtMoeda(double? valor) {
  return 'R\$ ${(valor ?? 0).toStringAsFixed(2).replaceAll('.', ',')}';
}
