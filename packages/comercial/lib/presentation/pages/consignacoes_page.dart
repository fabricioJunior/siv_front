import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';

class ConsignacoesPage extends StatelessWidget {
  const ConsignacoesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConsignacoesBloc>(
      create: (_) => sl<ConsignacoesBloc>()..add(const ConsignacoesIniciou()),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(title: const Text('Consignações')),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.of(context).pushNamed(
                  '/consignacao_abrir',
                );
                if (result == true && context.mounted) {
                  context
                      .read<ConsignacoesBloc>()
                      .add(const ConsignacoesIniciou());
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Nova consignação'),
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                context.read<ConsignacoesBloc>().add(
                      const ConsignacoesIniciou(),
                    );
              },
              child: BlocBuilder<ConsignacoesBloc, ConsignacoesState>(
                builder: (context, state) {
                  if (state.step == ConsignacoesStep.carregando ||
                      state.step == ConsignacoesStep.inicial) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }

                  if (state.step == ConsignacoesStep.falha) {
                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Text(
                          state.erro ?? 'Falha ao carregar consignações.',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    );
                  }

                  if (state.consignacoes.isEmpty) {
                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: const [
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'Nenhuma consignação encontrada.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.consignacoes.length,
                    itemBuilder: (context, index) {
                      final consignacao = state.consignacoes[index];
                      return _ConsignacaoCard(
                        consignacao: consignacao,
                        onTap: () async {
                          final result = await Navigator.of(context).pushNamed(
                            '/consignacao',
                            arguments: {'id': consignacao.id},
                          );
                          if (result == true && context.mounted) {
                            context
                                .read<ConsignacoesBloc>()
                                .add(const ConsignacoesIniciou());
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ConsignacaoCard extends StatelessWidget {
  final Consignacao consignacao;
  final VoidCallback onTap;

  const _ConsignacaoCard({required this.consignacao, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cor = _corDaSituacao(consignacao.situacao);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Consignação #${consignacao.id ?? '-'}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Chip(
                    label: Text(_labelSituacao(consignacao.situacao)),
                    backgroundColor: cor.withValues(alpha: 0.12),
                    labelStyle: TextStyle(color: cor, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(consignacao.nomePessoa ?? 'Cliente #${consignacao.pessoaId}'),
              const SizedBox(height: 6),
              Text(
                'Pendente: ${_formatarMoeda(consignacao.valorPendente ?? 0)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
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

  Color _corDaSituacao(SituacaoConsignacao? situacao) {
    switch (situacao) {
      case SituacaoConsignacao.em_andamento:
        return Colors.orange;
      case SituacaoConsignacao.encerrada:
        return Colors.green;
      case SituacaoConsignacao.cancelada:
        return Colors.red;
      case null:
        return Colors.grey;
    }
  }

  String _formatarMoeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}
