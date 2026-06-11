import 'package:estoque/domain/models/balanco.dart';
import 'package:estoque/presentation/bloc/balanco/balanco_bloc.dart';
import 'package:estoque/presentation/bloc/balanco/balanco_itens_bloc.dart';
import 'package:estoque/presentation/bloc/lotes/lotes_bloc.dart';
import 'package:estoque/routes/estoque_routes.dart';
import 'package:core/bloc.dart';
import 'package:flutter/material.dart';

class DetalhesBalancoPage extends StatefulWidget {
  final int balancoId;

  const DetalhesBalancoPage({Key? key, required this.balancoId})
    : super(key: key);

  @override
  State<DetalhesBalancoPage> createState() => _DetalhesBalancoPageState();
}

class _DetalhesBalancoPageState extends State<DetalhesBalancoPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Balanco? _balancoAtual;
  bool _acaoBalancoEmAndamento = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _carregarBalanco();
    _carregarItens();
    _carregarLotes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _carregarBalanco() {
    context.read<BalancoBloc>().add(
      ObterBalancoEvent(balancoId: widget.balancoId),
    );
  }

  void _carregarItens() {
    context.read<BalancoItensBloc>().add(
      CarregarItensDoBalancoEvent(balancoId: widget.balancoId),
    );
  }

  void _carregarLotes() {
    context.read<LotesBloc>().add(
      CarregarLotesEvent(balancoId: widget.balancoId),
    );
  }

  void _encerrarBalanco() async {
    if (_acaoBalancoEmAndamento) {
      return;
    }

    var result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Encerrar Balanço'),
        content: const Text(
          'Tem certeza que deseja encerrar este balanço? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('Encerrar'),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() {
        _acaoBalancoEmAndamento = true;
      });
      // ignore: use_build_context_synchronously
      context.read<BalancoBloc>().add(
        EncerrarBalancoEvent(balancoId: widget.balancoId),
      );
    }
  }

  void _cancelarBalanco() async {
    if (_acaoBalancoEmAndamento) {
      return;
    }

    var result = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Cancelar Balanço'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Motivo do Cancelamento',
              border: OutlineInputBorder(),
            ),
            minLines: 2,
            maxLines: 4,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Fechar'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  Navigator.pop(context, controller.text.trim());
                }
              },
              child: const Text('Cancelar Balanço'),
            ),
          ],
        );
      },
    );
    if (result?.isNotEmpty ?? false) {
      setState(() {
        _acaoBalancoEmAndamento = true;
      });
      // ignore: use_build_context_synchronously
      context.read<BalancoBloc>().add(
        CancelarBalancoEvent(balancoId: widget.balancoId, motivo: result!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Balanço #${widget.balancoId}'),
        bottom: TabBar(
          controller: _tabController,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Itens'),
            Tab(text: 'Lotes'),
          ],
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<BalancoBloc, BalancoState>(
            listener: (context, state) {
              if (state is BalancoLoaded) {
                setState(() {
                  _balancoAtual = state.balanco;
                });
              } else if (state is BalancoUpdated) {
                setState(() {
                  _balancoAtual = state.balanco;
                });
              } else if (state is BalancoFinalized) {
                setState(() {
                  _balancoAtual = state.balanco;
                  _acaoBalancoEmAndamento = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Balanço encerrado com sucesso'),
                  ),
                );
              } else if (state is BalancoCanceled) {
                setState(() {
                  _balancoAtual = state.balanco;
                  _acaoBalancoEmAndamento = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Balanço cancelado')),
                );
              } else if (state is BalancoError) {
                if (_acaoBalancoEmAndamento) {
                  setState(() {
                    _acaoBalancoEmAndamento = false;
                  });
                }
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
          ),
          BlocListener<BalancoItensBloc, BalancoItensState>(
            listener: (context, state) {
              if (state is BalancoItensError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
          ),
          BlocListener<LotesBloc, LotesState>(
            listener: (context, state) {
              if (state is LotesError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
          ),
        ],
        child: BlocBuilder<BalancoBloc, BalancoState>(
          builder: (context, state) {
            if (_balancoAtual == null && state is BalancoLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_balancoAtual == null && state is BalancoError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 16),
                    Text(state.message),
                  ],
                ),
              );
            }

            if (_balancoAtual != null) {
              final balanco = _balancoAtual!;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Resumo do balanço',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                Chip(
                                  label: Text(
                                    _getSituacaoLabel(balanco.situacao),
                                  ),
                                  backgroundColor: _getSituacaoCor(
                                    balanco.situacao,
                                  ).withOpacity(0.2),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Data: ${_formatDateTime(balanco.data)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'ID: ${balanco.id}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (balanco.observacao != null) ...[
                              const SizedBox(height: 10),
                              Text(
                                'Observação',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                balanco.observacao!,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                            if (balanco.emAndamento) ...[
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _acaoBalancoEmAndamento
                                          ? null
                                          : _cancelarBalanco,
                                      icon: _acaoBalancoEmAndamento
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(Icons.close, size: 18),
                                      label: const Text('Cancelar balanço'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        side: const BorderSide(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: _acaoBalancoEmAndamento
                                          ? null
                                          : _encerrarBalanco,
                                      icon: _acaoBalancoEmAndamento
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Icon(Icons.check, size: 18),
                                      label: const Text('Encerrar balanço'),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Aba de Itens
                        _ItensTab(
                          balancoId: widget.balancoId,
                          balancoEmAndamento: balanco.emAndamento,
                        ),
                        // Aba de Lotes
                        _LotesTab(
                          balancoId: widget.balancoId,
                          balancoEmAndamento: balanco.emAndamento,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  String _getSituacaoLabel(String situacao) {
    switch (situacao) {
      case 'em_andamento':
        return 'Em Andamento';
      case 'encerrado':
        return 'Encerrado';
      case 'cancelado':
        return 'Cancelado';
      default:
        return situacao;
    }
  }

  Color _getSituacaoCor(String situacao) {
    switch (situacao) {
      case 'em_andamento':
        return Colors.blue;
      case 'encerrado':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime value) {
    final d = value.day.toString().padLeft(2, '0');
    final m = value.month.toString().padLeft(2, '0');
    final y = value.year.toString();
    final h = value.hour.toString().padLeft(2, '0');
    final min = value.minute.toString().padLeft(2, '0');
    return '$d/$m/$y $h:$min';
  }
}

class _ItensTab extends StatelessWidget {
  final int balancoId;
  final bool balancoEmAndamento;

  const _ItensTab({required this.balancoId, required this.balancoEmAndamento});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BalancoItensBloc, BalancoItensState>(
      builder: (context, state) {
        if (state is BalancoItensError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 16),
                Text(state.message),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    context.read<BalancoItensBloc>().add(
                      CarregarItensDoBalancoEvent(balancoId: balancoId),
                    );
                  },
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }

        if (state is BalancoItensLoading || state is BalancoItensInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is BalancoItensLoaded) {
          if (state.itens.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inbox_outlined, size: 48),
                  const SizedBox(height: 16),
                  const Text('Nenhum item adicionado'),
                  if (balancoEmAndamento) ...[
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await Navigator.of(context).pushNamed(
                          EstoqueRoutes.adicionarItensBalanco,
                          arguments: {'balancoId': balancoId},
                        );
                        // ignore: use_build_context_synchronously
                        context.read<BalancoItensBloc>().add(
                          CarregarItensDoBalancoEvent(balancoId: balancoId),
                        );
                      },
                      child: const Text('Adicionar Itens'),
                    ),
                  ],
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: state.itens.length,
            itemBuilder: (context, index) {
              final item = state.itens[index];
              return BalancoItemCard(
                item: item,
                balancoId: balancoId,
                balancoEmAndamento: balancoEmAndamento,
              );
            },
          );
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Ainda não foi possível carregar os itens.'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  context.read<BalancoItensBloc>().add(
                    CarregarItensDoBalancoEvent(balancoId: balancoId),
                  );
                },
                child: const Text('Atualizar itens'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LotesTab extends StatelessWidget {
  final int balancoId;
  final bool balancoEmAndamento;

  const _LotesTab({required this.balancoId, required this.balancoEmAndamento});

  Future<void> _cancelarLote(BuildContext context, int loteId) async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancelar lote'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Motivo do cancelamento',
              border: OutlineInputBorder(),
            ),
            minLines: 2,
            maxLines: 4,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Fechar'),
            ),
            FilledButton(
              onPressed: () {
                final motivo = controller.text.trim();
                if (motivo.isEmpty) {
                  return;
                }

                Navigator.pop(dialogContext);
                context.read<LotesBloc>().add(
                  CancelarLoteDaListaEvent(
                    balancoId: balancoId,
                    loteId: loteId,
                    motivo: motivo,
                  ),
                );
              },
              child: const Text('Cancelar lote'),
            ),
          ],
        );
      },
    );
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LotesBloc, LotesState>(
      builder: (context, state) {
        if (state is LotesError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 16),
                Text(state.message),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    context.read<LotesBloc>().add(
                      CarregarLotesEvent(balancoId: balancoId),
                    );
                  },
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }

        if (state is LotesLoading || state is LotesInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is LotesLoaded) {
          if (state.lotes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.layers_outlined, size: 48),
                  const SizedBox(height: 16),
                  const Text('Nenhum lote criado'),
                  if (balancoEmAndamento) ...[
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await Navigator.of(context).pushNamed(
                          EstoqueRoutes.criarLoteBalanco,
                          arguments: {'balancoId': balancoId},
                        );
                        // ignore: use_build_context_synchronously
                        context.read<LotesBloc>().add(
                          CarregarLotesEvent(balancoId: balancoId),
                        );
                      },
                      child: const Text('Criar Lote'),
                    ),
                  ],
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: state.lotes.length,
            itemBuilder: (context, index) {
              final lote = state.lotes[index];
              return BalancoLoteCard(
                lote: lote,
                balancoId: balancoId,
                balancoEmAndamento: balancoEmAndamento,
                onCancelar: () => _cancelarLote(context, lote.id),
                onTap: () {
                  Navigator.of(context).pushNamed(
                    EstoqueRoutes.detalhesLoteBalanco,
                    arguments: {
                      'balancoId': balancoId,
                      'loteId': lote.id,
                      'balancoFinalizado': !balancoEmAndamento,
                    },
                  );
                },
              );
            },
          );
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Ainda não foi possível carregar os lotes.'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  context.read<LotesBloc>().add(
                    CarregarLotesEvent(balancoId: balancoId),
                  );
                },
                child: const Text('Atualizar lotes'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class BalancoItemCard extends StatelessWidget {
  final BalancoItem item;
  final int balancoId;
  final bool balancoEmAndamento;

  const BalancoItemCard({
    Key? key,
    required this.item,
    required this.balancoId,
    required this.balancoEmAndamento,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tituloProduto = (item.produtoNome?.trim().isNotEmpty ?? false)
        ? item.produtoNome!.trim()
        : 'Produto #${item.produtoId}';

    final detalhesProduto = <String>[];
    if (item.referencia?.trim().isNotEmpty ?? false) {
      detalhesProduto.add('Ref: ${item.referencia!.trim()}');
    }
    if (item.cor?.trim().isNotEmpty ?? false) {
      detalhesProduto.add('Cor: ${item.cor!.trim()}');
    }
    if (item.tamanho?.trim().isNotEmpty ?? false) {
      detalhesProduto.add('Tam: ${item.tamanho!.trim()}');
    }

    final quantidades =
        'Original: ${item.quantidadeOriginal.toStringAsFixed(2)} | Contada: ${item.quantidadeContada.toStringAsFixed(2)}';

    final subtitleParts = [
      if (detalhesProduto.isNotEmpty) detalhesProduto.join('  •  '),
      quantidades,
    ];

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.12),
          child: const Icon(Icons.inventory_2_outlined, color: Colors.blue),
        ),
        title: Text(tituloProduto),
        subtitle: Text(subtitleParts.join('\n')),
        trailing: balancoEmAndamento
            ? IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  context.read<BalancoItensBloc>().add(
                    RemoverItemDoBalancoItensEvent(
                      balancoId: balancoId,
                      produtoId: item.produtoId,
                    ),
                  );
                },
              )
            : null,
      ),
    );
  }
}

class BalancoLoteCard extends StatelessWidget {
  final BalancoLote lote;
  final int balancoId;
  final bool balancoEmAndamento;
  final VoidCallback onTap;
  final VoidCallback onCancelar;

  const BalancoLoteCard({
    Key? key,
    required this.lote,
    required this.balancoId,
    required this.balancoEmAndamento,
    required this.onTap,
    required this.onCancelar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: lote.ativo
              ? Colors.green.withOpacity(0.15)
              : Colors.red.withOpacity(0.15),
          child: Icon(
            Icons.layers_outlined,
            color: lote.ativo ? Colors.green : Colors.red,
          ),
        ),
        title: Text('Lote: ${lote.lote}'),
        subtitle: Text('Situação: ${lote.ativo ? "Ativo" : "Cancelado"}'),
        trailing: Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (balancoEmAndamento && lote.ativo)
              IconButton(
                tooltip: 'Cancelar lote',
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: onCancelar,
              ),
            Chip(
              label: Text(lote.ativo ? 'Ativo' : 'Cancelado'),
              backgroundColor: lote.ativo
                  ? Colors.green.withOpacity(0.2)
                  : Colors.red.withOpacity(0.2),
            ),
          ],
        ),
      ),
    );
  }
}
