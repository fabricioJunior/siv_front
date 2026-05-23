import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:financeiro/models.dart';
import 'package:financeiro/presentation.dart';
import 'package:flutter/material.dart';

class FechamentoDeCaixaPage extends StatefulWidget {
  final int caixaId;

  const FechamentoDeCaixaPage({
    super.key,
    required this.caixaId,
  });

  @override
  State<FechamentoDeCaixaPage> createState() => _FechamentoDeCaixaPageState();
}

class _FechamentoDeCaixaPageState extends State<FechamentoDeCaixaPage> {
  bool _confirmouConferencia = false;

  void _recarregarConferencia() {
    _confirmouConferencia = false;
    context.read<FechamentoDeCaixaBloc>().add(
          FechamentoDeCaixaRecarregarSolicitado(caixaId: widget.caixaId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FechamentoDeCaixaBloc>(
      create: (_) => sl<FechamentoDeCaixaBloc>()
        ..add(FechamentoDeCaixaIniciou(caixaId: widget.caixaId)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Fechamento de caixa')),
        body: BlocBuilder<FechamentoDeCaixaBloc, FechamentoDeCaixaState>(
          builder: (context, state) {
            if (state.step == FechamentoDeCaixaStep.carregando ||
                state.step == FechamentoDeCaixaStep.inicial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.step == FechamentoDeCaixaStep.falha) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 36),
                      const SizedBox(height: 12),
                      Text(
                        state.erro ??
                            'Falha ao carregar os valores para conferencia do fechamento.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _recarregarConferencia,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final itens = state.itens;
            final totalEsperado = itens.fold<double>(
              0,
              (total, item) => total + item.valorEsperado,
            );
            final totalContado = itens.fold<double>(
              0,
              (total, item) => total + item.valorContado,
            );
            final diferencaTotal = (totalContado - totalEsperado).abs();
            final possuiDivergencia = diferencaTotal >= 0.01;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _EtapaCard(
                titulo: 'Fluxo de fechamento',
                descricao:
                    '1. Contagem dos pendentes  •  2. Confirmacao dos valores  •  3. Fechamento concreto',
                icone: Icons.rule_folder_outlined,
              ),
              const SizedBox(height: 10),
              _EtapaCard(
                titulo: 'Etapa 2 de 3: Confirmacao dos valores contados',
                descricao: 'Caixa #${widget.caixaId}',
                icone: Icons.fact_check_outlined,
              ),
              const SizedBox(height: 12),
              if (itens.isEmpty)
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.check_circle_outline, color: Colors.green),
                    title: Text('Nao ha itens pendentes para conferencia.'),
                  ),
                )
              else
                ...itens.map((item) => _ItemConferenciaTile(item: item)),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Resumo da conferencia',
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 6),
                      Text('Total esperado: ${_formatarMoeda(totalEsperado)}'),
                      Text('Total contado: ${_formatarMoeda(totalContado)}'),
                      Text(
                        'Diferenca: ${_formatarMoeda(diferencaTotal)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color:
                              possuiDivergencia ? Colors.orange : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (possuiDivergencia) ...[
                const SizedBox(height: 8),
                Card(
                  color: Colors.orange.withValues(alpha: 0.08),
                  child: const ListTile(
                    leading: Icon(Icons.warning_amber_rounded),
                    title: Text('Fechamento bloqueado por divergencia'),
                    subtitle: Text(
                      'A contagem deve bater com o valor esperado para fechar o caixa.',
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              CheckboxListTile(
                value: _confirmouConferencia,
                onChanged: possuiDivergencia
                    ? null
                    : (value) {
                  setState(() {
                    _confirmouConferencia = value ?? false;
                  });
                },
                contentPadding: EdgeInsets.zero,
                title: const Text('Confirmo os valores contados e esperados'),
                subtitle: Text(
                  possuiDivergencia
                      ? 'Corrija a divergencia para liberar o fechamento.'
                      : 'Ao confirmar, o fechamento concreto do caixa sera executado.',
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: !_confirmouConferencia || possuiDivergencia
                    ? null
                    : () {
                        Navigator.of(context).pop(true);
                      },
                icon: const Icon(Icons.lock_outline),
                label: const Text('Confirmar e fechar caixa'),
              ),
            ],
          );
          },
        ),
      ),
    );
  }
}

class _EtapaCard extends StatelessWidget {
  final String titulo;
  final String descricao;
  final IconData icone;

  const _EtapaCard({
    required this.titulo,
    required this.descricao,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icone),
        title: Text(titulo),
        subtitle: Text(descricao),
      ),
    );
  }
}

class _ItemConferenciaTile extends StatelessWidget {
  final ConferenciaFechamentoItem item;

  const _ItemConferenciaTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final diferenca = item.valorContado - item.valorEsperado;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(_iconeTipo(item.tipo)),
        title: Text(_labelTipo(item.tipo)),
        subtitle: Text(
          'Esperado: ${_formatarMoeda(item.valorEsperado)}\nContado: ${_formatarMoeda(item.valorContado)}',
        ),
        trailing: Text(
          _formatarMoeda(diferenca.abs()),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: diferenca.abs() < 0.01 ? Colors.green : Colors.orange,
          ),
        ),
      ),
    );
  }
}

String _labelTipo(TipoContagemDoCaixaItem tipo) {
  switch (tipo) {
    case TipoContagemDoCaixaItem.dinheiro:
      return 'Dinheiro';
    case TipoContagemDoCaixaItem.pix:
      return 'Pix';
    case TipoContagemDoCaixaItem.cartao:
      return 'Cartao';
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
      return 'Credito de devolucao';
  }
}

IconData _iconeTipo(TipoContagemDoCaixaItem tipo) {
  switch (tipo) {
    case TipoContagemDoCaixaItem.dinheiro:
      return Icons.payments_outlined;
    case TipoContagemDoCaixaItem.pix:
      return Icons.pix;
    case TipoContagemDoCaixaItem.cartao:
      return Icons.credit_card_outlined;
    case TipoContagemDoCaixaItem.fatura:
      return Icons.receipt_long_outlined;
    case TipoContagemDoCaixaItem.cheque:
      return Icons.request_quote_outlined;
    case TipoContagemDoCaixaItem.troco:
      return Icons.currency_exchange;
    case TipoContagemDoCaixaItem.voucher:
      return Icons.confirmation_number_outlined;
    case TipoContagemDoCaixaItem.tedDoc:
      return Icons.swap_horiz_outlined;
    case TipoContagemDoCaixaItem.adiantamento:
      return Icons.trending_up_outlined;
    case TipoContagemDoCaixaItem.creditoDeDevolucao:
      return Icons.assignment_return_outlined;
  }
}

String _formatarMoeda(double valor) {
  return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
}
