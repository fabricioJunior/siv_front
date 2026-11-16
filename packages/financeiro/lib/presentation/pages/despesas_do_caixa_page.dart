import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:financeiro/models.dart';
import 'package:financeiro/presentation.dart';
import 'package:flutter/material.dart';

class DespesasDoCaixaPage extends StatefulWidget {
  final int caixaId;

  const DespesasDoCaixaPage({
    super.key,
    required this.caixaId,
  });

  @override
  State<DespesasDoCaixaPage> createState() => _DespesasDoCaixaPageState();
}

class _DespesasDoCaixaPageState extends State<DespesasDoCaixaPage> {
  Future<void> _atualizar(BuildContext blocContext) async {
    blocContext.read<DespesasDoCaixaBloc>().add(DespesasDoCaixaRecarregarSolicitado());
  }

  Future<void> _novaDespesa(BuildContext blocContext) async {
    final resultado = await Navigator.of(blocContext).pushNamed(
      '/despesa_do_caixa',
      arguments: {'caixaId': widget.caixaId},
    );

    if (!mounted || resultado != true) {
      return;
    }
    if (mounted) {
      // ignore: use_build_context_synchronously
      await _atualizar(blocContext);
    }
  }

  Future<void> _cancelarDespesa(
    BuildContext blocContext,
    DespesaDoCaixa despesa,
  ) async {
    final motivo = await _solicitarMotivo();
    if (!mounted || motivo == null) {
      return;
    }

    blocContext.read<DespesasDoCaixaBloc>().add(
          DespesaDoCaixaExclusaoSolicitada(
            despesaId: despesa.id,
            motivo: motivo,
          ),
        );
  }

  Future<String?> _solicitarMotivo() async {
    final controller = TextEditingController();

    final resultado = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancelar despesa'),
          content: TextField(
            controller: controller,
            autofocus: true,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Motivo do cancelamento',
              hintText: 'Informe o motivo',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final motivo = controller.text.trim();
                if (motivo.isEmpty) {
                  return;
                }
                Navigator.of(dialogContext).pop(motivo);
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (resultado == null) {
      return null;
    }

    if (resultado.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('É obrigatório informar o motivo.')),
        );
      }
      return null;
    }

    return resultado;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DespesasDoCaixaBloc>(
      create: (_) =>
          sl<DespesasDoCaixaBloc>()..add(DespesasDoCaixaIniciou(caixaId: widget.caixaId)),
      child: BlocConsumer<DespesasDoCaixaBloc, DespesasDoCaixaState>(
        listenWhen: (previous, current) =>
            previous.step != current.step || previous.erro != current.erro,
        listener: (context, state) {
          if (state.step == DespesasDoCaixaStep.cancelado) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Despesa cancelada com sucesso.')),
            );
          }

          if (state.step == DespesasDoCaixaStep.falha && state.erro != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.erro!)),
            );
          }
        },
        builder: (blocContext, state) {
          final processando = state.step == DespesasDoCaixaStep.carregando ||
              state.step == DespesasDoCaixaStep.cancelando;
          final despesas = state.despesas;

          return Scaffold(
            appBar: AppBar(title: const Text('Despesas do caixa')),
            floatingActionButton: FloatingActionButton(
              onPressed: processando ? null : () => _novaDespesa(blocContext),
              child: const Icon(Icons.add),
            ),
            body: Column(
              children: [
                Card(
                  margin: const EdgeInsets.all(16),
                  child: ListTile(
                    leading: const Icon(Icons.point_of_sale_outlined),
                    title: Text('Caixa #${widget.caixaId}'),
                    subtitle: const Text(
                      'Despesas pagas em dinheiro do caixa.',
                    ),
                  ),
                ),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (state.step == DespesasDoCaixaStep.carregando &&
                          despesas.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      }

                      if (state.step == DespesasDoCaixaStep.falha &&
                          despesas.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.error_outline, size: 42),
                                const SizedBox(height: 12),
                                Text(
                                  state.erro ??
                                      'Falha ao carregar as despesas deste caixa.',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                FilledButton(
                                  onPressed: () => _atualizar(blocContext),
                                  child: const Text('Tentar novamente'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (despesas.isEmpty) {
                        return RefreshIndicator(
                          onRefresh: () => _atualizar(blocContext),
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 120),
                              Icon(Icons.inbox_outlined, size: 48),
                              SizedBox(height: 12),
                              Center(
                                child: Text(
                                  'Nenhuma despesa lançada para este caixa.',
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () => _atualizar(blocContext),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                          itemCount: despesas.length,
                          itemBuilder: (context, index) {
                            final despesa = despesas[index];
                            return _DespesaCard(
                              despesa: despesa,
                              processando: processando,
                              onExcluir: despesa.cancelado
                                  ? null
                                  : () =>
                                      _cancelarDespesa(blocContext, despesa),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DespesaCard extends StatelessWidget {
  final DespesaDoCaixa despesa;
  final bool processando;
  final VoidCallback? onExcluir;

  const _DespesaCard({
    required this.despesa,
    required this.processando,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = despesa.cancelado ? Colors.red : Colors.green;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Despesa #${despesa.id}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Chip(
                  label: Text(despesa.cancelado ? 'Cancelado' : 'Ativo'),
                  avatar: Icon(
                    despesa.cancelado ? Icons.block : Icons.check_circle,
                    size: 16,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Valor: ${_formatarMoeda(despesa.valor)}'),
            const SizedBox(height: 4),
            Text('Categoria: ${despesa.categoriaNome ?? '-'}'),
            const SizedBox(height: 4),
            Text('Descrição: ${despesa.descricao}'),
            if (despesa.motivoCancelamento != null &&
                despesa.motivoCancelamento!.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Motivo do cancelamento: ${despesa.motivoCancelamento}'),
            ],
            if (onExcluir != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: processando ? null : onExcluir,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Cancelar'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatarMoeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}
