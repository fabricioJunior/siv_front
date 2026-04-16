import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:financeiro/models.dart';
import 'package:financeiro/presentation.dart';
import 'package:flutter/material.dart';

class SuprimentosPage extends StatefulWidget {
  final int caixaId;

  const SuprimentosPage({
    super.key,
    required this.caixaId,
  });

  @override
  State<SuprimentosPage> createState() => _SuprimentosPageState();
}

class _SuprimentosPageState extends State<SuprimentosPage> {
  Future<void> _atualizar() async {
    context.read<SuprimentosBloc>().add(SuprimentosRecarregarSolicitado());
  }

  Future<void> _novoSuprimento() async {
    final resultado = await Navigator.of(context).pushNamed(
      '/suprimento',
      arguments: {'caixaId': widget.caixaId},
    );

    if (!mounted || resultado != true) {
      return;
    }

    await _atualizar();
  }

  Future<void> _cancelarSuprimento(Suprimento suprimento) async {
    final motivo = await _solicitarMotivo();
    if (!mounted || motivo == null || suprimento.id == null) {
      return;
    }

    context.read<SuprimentosBloc>().add(
          SuprimentoExclusaoSolicitada(
            suprimentoId: suprimento.id!,
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
          title: const Text('Excluir suprimento'),
          content: TextField(
            controller: controller,
            autofocus: true,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Motivo da exclusão',
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
    return BlocProvider<SuprimentosBloc>(
      create: (_) => sl<SuprimentosBloc>()
        ..add(SuprimentosIniciou(caixaId: widget.caixaId)),
      child: BlocConsumer<SuprimentosBloc, SuprimentosState>(
        listenWhen: (previous, current) =>
            previous.step != current.step || previous.erro != current.erro,
        listener: (context, state) {
          if (state.step == SuprimentosStep.cancelado) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Suprimento excluído com sucesso.')),
            );
          }

          if (state.step == SuprimentosStep.falha && state.erro != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.erro!)),
            );
          }
        },
        builder: (context, state) {
          final processando = state.step == SuprimentosStep.carregando ||
              state.step == SuprimentosStep.cancelando;
          final suprimentos = state.suprimentos;

          return Scaffold(
            appBar: AppBar(title: const Text('Suprimentos do caixa')),
            floatingActionButton: FloatingActionButton(
              onPressed: processando ? null : _novoSuprimento,
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
                      'Os suprimentos representam entradas de valores no caixa.',
                    ),
                  ),
                ),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (state.step == SuprimentosStep.carregando &&
                          suprimentos.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      }

                      if (state.step == SuprimentosStep.falha &&
                          suprimentos.isEmpty) {
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
                                      'Falha ao carregar os suprimentos deste caixa.',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                FilledButton(
                                  onPressed: _atualizar,
                                  child: const Text('Tentar novamente'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (suprimentos.isEmpty) {
                        return RefreshIndicator(
                          onRefresh: _atualizar,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 120),
                              Icon(Icons.inbox_outlined, size: 48),
                              SizedBox(height: 12),
                              Center(
                                child: Text(
                                  'Nenhum suprimento cadastrado para este caixa.',
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: _atualizar,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                          itemCount: suprimentos.length,
                          itemBuilder: (context, index) {
                            final suprimento = suprimentos[index];
                            return _SuprimentoCard(
                              suprimento: suprimento,
                              processando: processando,
                              onExcluir:
                                  suprimento.cancelado || suprimento.id == null
                                      ? null
                                      : () => _cancelarSuprimento(suprimento),
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

class _SuprimentoCard extends StatelessWidget {
  final Suprimento suprimento;
  final bool processando;
  final VoidCallback? onExcluir;

  const _SuprimentoCard({
    required this.suprimento,
    required this.processando,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = suprimento.cancelado ? Colors.red : Colors.green;

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
                    'Suprimento #${suprimento.id ?? '-'}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Chip(
                  label: Text(suprimento.cancelado ? 'Cancelado' : 'Ativo'),
                  avatar: Icon(
                    suprimento.cancelado ? Icons.block : Icons.check_circle,
                    size: 16,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Valor: ${_formatarMoeda(suprimento.valor)}'),
            const SizedBox(height: 4),
            Text('Descrição: ${suprimento.descricao}'),
            if (suprimento.motivoCancelamento != null &&
                suprimento.motivoCancelamento!.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Motivo da exclusão: ${suprimento.motivoCancelamento}'),
            ],
            if (onExcluir != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: processando ? null : onExcluir,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Excluir'),
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
