import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/produtos_compartilhados.dart';
import 'package:flutter/material.dart';

class ConsignacaoDetalhePage extends StatelessWidget {
  final int id;

  const ConsignacaoDetalhePage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConsignacaoDetalheBloc>(
      create: (_) => sl<ConsignacaoDetalheBloc>()
        ..add(ConsignacaoDetalheCarregarSolicitado(id: id)),
      child: Builder(
        builder: (context) {
          return BlocConsumer<ConsignacaoDetalheBloc, ConsignacaoDetalheState>(
            listenWhen: (previous, current) => previous.erro != current.erro,
            listener: (context, state) {
              if (state.erro != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.erro!)),
                );
              }
            },
            builder: (context, state) {
              final consignacao = state.consignacao;

              return Scaffold(
                appBar: AppBar(title: Text('Consignação #$id')),
                body: state.step == ConsignacaoDetalheStep.carregando ||
                        consignacao == null
                    ? const Center(child: CircularProgressIndicator.adaptive())
                    : RefreshIndicator(
                        onRefresh: () async {
                          context.read<ConsignacaoDetalheBloc>().add(
                                ConsignacaoDetalheCarregarSolicitado(id: id),
                              );
                        },
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            _CabecalhoCard(consignacao: consignacao),
                            const SizedBox(height: 12),
                            _ResumoCard(consignacao: consignacao),
                            const SizedBox(height: 12),
                            _AcoesCard(
                              consignacao: consignacao,
                              processando: state.processando,
                            ),
                            const SizedBox(height: 12),
                            _ItensCard(consignacao: consignacao),
                          ],
                        ),
                      ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CabecalhoCard extends StatelessWidget {
  final Consignacao consignacao;

  const _CabecalhoCard({required this.consignacao});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              consignacao.nomePessoa ?? 'Cliente #${consignacao.pessoaId}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text('Vendedor: ${consignacao.nomeFuncionario ?? '-'}'),
            Text(
              'Abertura: ${_formatarData(consignacao.dataAbertura)}'
              '${consignacao.previsaoFechamento != null ? ' • Previsão: ${_formatarData(consignacao.previsaoFechamento)}' : ''}',
            ),
            if (consignacao.dataFechamento != null)
              Text('Fechamento: ${_formatarData(consignacao.dataFechamento)}'),
            if (consignacao.observacao != null &&
                consignacao.observacao!.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('Observação: ${consignacao.observacao}'),
              ),
            if (consignacao.motivoCancelamento != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Motivo do cancelamento: ${consignacao.motivoCancelamento}',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 8),
            Chip(label: Text(_labelSituacao(consignacao.situacao))),
          ],
        ),
      ),
    );
  }

  String _labelSituacao(SituacaoConsignacao? situacao) {
    switch (situacao) {
      case SituacaoConsignacao.em_andamento:
        return 'Em andamento';
      case SituacaoConsignacao.encerrada:
        return 'Encerrada';
      case SituacaoConsignacao.cancelada:
        return 'Cancelada';
      case null:
        return '-';
    }
  }

  String _formatarData(DateTime? data) {
    if (data == null) return '-';
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/${data.year}';
  }
}

class _ResumoCard extends StatelessWidget {
  final Consignacao consignacao;

  const _ResumoCard({required this.consignacao});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resumo', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ResumoItem(
                  titulo: 'Solicitado',
                  quantidade: consignacao.solicitado,
                  valor: consignacao.valorSolicitado,
                ),
                _ResumoItem(
                  titulo: 'Devolvido',
                  quantidade: consignacao.devolvido,
                  valor: consignacao.valorDevolvido,
                ),
                _ResumoItem(
                  titulo: 'Acertado',
                  quantidade: consignacao.acertado,
                  valor: consignacao.valorAcertado,
                ),
                _ResumoItem(
                  titulo: 'Pendente',
                  quantidade: consignacao.pendente,
                  valor: consignacao.valorPendente,
                  destaque: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumoItem extends StatelessWidget {
  final String titulo;
  final double? quantidade;
  final double? valor;
  final bool destaque;

  const _ResumoItem({
    required this.titulo,
    required this.quantidade,
    required this.valor,
    this.destaque = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: destaque
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text('Qtd: ${quantidade ?? 0}'),
          Text(
            _formatarMoeda(valor ?? 0),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  String _formatarMoeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}

class _AcoesCard extends StatelessWidget {
  final Consignacao consignacao;
  final bool processando;

  const _AcoesCard({required this.consignacao, required this.processando});

  bool get _emAndamento =>
      consignacao.situacao == SituacaoConsignacao.em_andamento;

  @override
  Widget build(BuildContext context) {
    if (!_emAndamento) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pushNamed(
              '/consignacao_extrato',
              arguments: {'pessoaId': consignacao.pessoaId},
            ),
            icon: const Icon(Icons.receipt_long_outlined),
            label: const Text('Ver extrato do cliente'),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: () async {
                final result = await Navigator.of(context).pushNamed(
                  '/consignacao_bipagem',
                  arguments: {
                    'consignacaoId': consignacao.id,
                    'pessoaId': consignacao.pessoaId,
                    'funcionarioId': consignacao.funcionarioId,
                    'tabelaPrecoId': consignacao.tabelaPrecoId,
                    'origem': OrigemCompartilhadaTipo.consignacaoSaida.name,
                  },
                );
                if (result == true && context.mounted) {
                  context.read<ConsignacaoDetalheBloc>().add(
                        ConsignacaoDetalheCarregarSolicitado(
                          id: consignacao.id!,
                        ),
                      );
                }
              },
              icon: const Icon(Icons.add_box_outlined),
              label: const Text('Adicionar produtos'),
            ),
            OutlinedButton.icon(
              onPressed: consignacao.itens.isEmpty
                  ? null
                  : () async {
                      final romaneiosOrigem = consignacao.itens
                          .map((item) => item.romaneioId)
                          .whereType<int>()
                          .toSet()
                          .toList();

                      final result = await Navigator.of(context).pushNamed(
                        '/consignacao_bipagem',
                        arguments: {
                          'consignacaoId': consignacao.id,
                          'pessoaId': consignacao.pessoaId,
                          'funcionarioId': consignacao.funcionarioId,
                          'tabelaPrecoId': consignacao.tabelaPrecoId,
                          'origem':
                              OrigemCompartilhadaTipo.consignacaoDevolucao.name,
                          'romaneiosConsignacao': romaneiosOrigem,
                        },
                      );
                      if (result == true && context.mounted) {
                        context.read<ConsignacaoDetalheBloc>().add(
                              ConsignacaoDetalheCarregarSolicitado(
                                id: consignacao.id!,
                              ),
                            );
                      }
                    },
              icon: const Icon(Icons.assignment_return_outlined),
              label: const Text('Registrar devolução'),
            ),
            OutlinedButton.icon(
              onPressed: (consignacao.pendente ?? 0) <= 0
                  ? null
                  : () async {
                      final result = await Navigator.of(context).pushNamed(
                        '/consignacao_acerto',
                        arguments: {'consignacao': consignacao},
                      );
                      if (result == true && context.mounted) {
                        context.read<ConsignacaoDetalheBloc>().add(
                              ConsignacaoDetalheCarregarSolicitado(
                                id: consignacao.id!,
                              ),
                            );
                      }
                    },
              icon: const Icon(Icons.point_of_sale_outlined),
              label: const Text('Finalizar consignação'),
            ),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed(
                '/consignacao_extrato',
                arguments: {'pessoaId': consignacao.pessoaId},
              ),
              icon: const Icon(Icons.receipt_long_outlined),
              label: const Text('Ver extrato do cliente'),
            ),
            TextButton.icon(
              onPressed: processando
                  ? null
                  : () => _cancelar(context),
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Cancelar consignação'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cancelar(BuildContext context) async {
    final controller = TextEditingController();
    final motivo = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancelar consignação'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Motivo do cancelamento',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Voltar'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text.trim()),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (motivo == null || motivo.isEmpty || !context.mounted) return;

    context.read<ConsignacaoDetalheBloc>().add(
          ConsignacaoDetalheCancelarSolicitado(motivoCancelamento: motivo),
        );
  }
}

class _ItensCard extends StatelessWidget {
  final Consignacao consignacao;

  const _ItensCard({required this.consignacao});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Itens', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (consignacao.itens.isEmpty)
              const Text('Nenhum item vinculado a esta consignação.')
            else
              ...consignacao.itens.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Produto #${item.produtoId} • Romaneio #${item.romaneioId}',
                        ),
                      ),
                      Text('Pendente: ${item.pendente ?? 0}'),
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
