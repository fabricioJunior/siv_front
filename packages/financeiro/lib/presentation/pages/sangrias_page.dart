import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:financeiro/models.dart';
import 'package:financeiro/presentation.dart';
import 'package:flutter/material.dart';

class SangriasPage extends StatefulWidget {
  final int caixaId;

  const SangriasPage({
    super.key,
    required this.caixaId,
  });

  @override
  State<SangriasPage> createState() => _SangriasPageState();
}

class _SangriasPageState extends State<SangriasPage> {
  Future<void> _atualizar(BuildContext blocContext) async {
    blocContext.read<SangriasBloc>().add(SangriasRecarregarSolicitado());
  }

  Future<void> _novaSangria(BuildContext blocContext) async {
    final resultado = await Navigator.of(blocContext).pushNamed(
      '/sangria',
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

  Future<void> _cancelarSangria(
    BuildContext blocContext,
    Sangria sangria,
  ) async {
    final motivo = await _solicitarMotivo();
    if (!mounted || motivo == null || sangria.id == null) {
      return;
    }

    blocContext.read<SangriasBloc>().add(
          SangriaExclusaoSolicitada(
            sangriaId: sangria.id!,
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
          title: const Text('Excluir sangria'),
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
    return BlocProvider<SangriasBloc>(
      create: (_) =>
          sl<SangriasBloc>()..add(SangriasIniciou(caixaId: widget.caixaId)),
      child: BlocConsumer<SangriasBloc, SangriasState>(
        listenWhen: (previous, current) =>
            previous.step != current.step || previous.erro != current.erro,
        listener: (context, state) {
          if (state.step == SangriasStep.cancelado) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sangria excluída com sucesso.')),
            );
          }

          if (state.step == SangriasStep.falha && state.erro != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.erro!)),
            );
          }
        },
        builder: (blocContext, state) {
          final processando = state.step == SangriasStep.carregando ||
              state.step == SangriasStep.cancelando;
          final sangrias = state.sangrias;

          return Scaffold(
            appBar: AppBar(title: const Text('Sangrias do caixa')),
            floatingActionButton: FloatingActionButton(
              onPressed: processando ? null : () => _novaSangria(blocContext),
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
                      'As sangrias representam saídas de valores do caixa.',
                    ),
                  ),
                ),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (state.step == SangriasStep.carregando &&
                          sangrias.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      }

                      if (state.step == SangriasStep.falha &&
                          sangrias.isEmpty) {
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
                                      'Falha ao carregar as sangrias deste caixa.',
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

                      if (sangrias.isEmpty) {
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
                                  'Nenhuma sangria cadastrada para este caixa.',
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
                          itemCount: sangrias.length,
                          itemBuilder: (context, index) {
                            final sangria = sangrias[index];
                            return _SangriaCard(
                              sangria: sangria,
                              processando: processando,
                              onExcluir: sangria.cancelado || sangria.id == null
                                  ? null
                                  : () =>
                                      _cancelarSangria(blocContext, sangria),
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

class _SangriaCard extends StatelessWidget {
  final Sangria sangria;
  final bool processando;
  final VoidCallback? onExcluir;

  const _SangriaCard({
    required this.sangria,
    required this.processando,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = sangria.cancelado ? Colors.red : Colors.green;

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
                    'Sangria #${sangria.id ?? '-'}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Chip(
                  label: Text(sangria.cancelado ? 'Cancelado' : 'Ativo'),
                  avatar: Icon(
                    sangria.cancelado ? Icons.block : Icons.check_circle,
                    size: 16,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Valor: ${_formatarMoeda(sangria.valor)}'),
            const SizedBox(height: 4),
            Text('Origem: ${sangria.origem}'),
            const SizedBox(height: 4),
            Text('Descrição: ${sangria.descricao}'),
            if (sangria.motivoCancelamento != null &&
                sangria.motivoCancelamento!.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Motivo da exclusão: ${sangria.motivoCancelamento}'),
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
