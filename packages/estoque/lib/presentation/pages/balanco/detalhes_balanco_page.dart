import 'package:estoque/domain/models/balanco.dart';
import 'package:estoque/presentation/bloc/balanco/balanco_bloc.dart';
import 'package:estoque/presentation/bloc/balanco/balanco_itens_bloc.dart';
import 'package:estoque/presentation/bloc/lotes/lotes_bloc.dart';
import 'package:estoque/routes/estoque_routes.dart';
import 'package:core/bloc.dart';
import 'package:core/presentation.dart';
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
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            color: _getSituacaoCor(balanco.situacao).withOpacity(0.07),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: _getSituacaoCor(balanco.situacao).withOpacity(0.15),
                                  child: Icon(Icons.inventory_2_outlined, size: 18, color: _getSituacaoCor(balanco.situacao)),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Balanço #${balanco.id}',
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today_outlined, size: 11, color: Colors.grey.shade600),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatDateTime(balanco.data),
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Chip(
                                  label: Text(
                                    _getSituacaoLabel(balanco.situacao),
                                    style: TextStyle(
                                      color: _getSituacaoCor(balanco.situacao),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  backgroundColor: _getSituacaoCor(balanco.situacao).withOpacity(0.12),
                                  side: BorderSide(color: _getSituacaoCor(balanco.situacao).withOpacity(0.4)),
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(horizontal: 2),
                                ),
                              ],
                            ),
                          ),
                          if (balanco.observacao != null) ...[
                            const Divider(height: 1),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              child: Row(
                                children: [
                                  Icon(Icons.notes_outlined, size: 14, color: Colors.grey.shade500),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      balanco.observacao!,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (balanco.emAndamento) ...[
                            const Divider(height: 1),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _acaoBalancoEmAndamento ? null : _cancelarBalanco,
                                      icon: _acaoBalancoEmAndamento
                                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                          : const Icon(Icons.close, size: 16),
                                      label: const Text('Cancelar'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        side: const BorderSide(color: Colors.red),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: BlocBuilder<BalancoItensBloc, BalancoItensState>(
                                      builder: (context, itensState) {
                                        final calculando = itensState is BalancoItensLoading;
                                        return OutlinedButton.icon(
                                          onPressed: (_acaoBalancoEmAndamento || calculando)
                                              ? null
                                              : () => context.read<BalancoItensBloc>().add(
                                                    CalcularItensDoBalancoEvent(balancoId: widget.balancoId),
                                                  ),
                                          icon: calculando
                                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                              : const Icon(Icons.calculate_outlined, size: 16),
                                          label: const Text('Calcular'),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: _acaoBalancoEmAndamento ? null : _encerrarBalanco,
                                      icon: _acaoBalancoEmAndamento
                                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                          : const Icon(Icons.check, size: 16),
                                      label: const Text('Encerrar'),
                                      style: FilledButton.styleFrom(backgroundColor: Colors.green),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
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

  String _formatDateTime(DateTime value) => formatarDataHora(value);
}

class _ItensTab extends StatefulWidget {
  final int balancoId;
  final bool balancoEmAndamento;

  const _ItensTab({required this.balancoId, required this.balancoEmAndamento});

  @override
  State<_ItensTab> createState() => _ItensTabState();
}

class _ItensTabState extends State<_ItensTab> {
  bool? _comDivergencia;
  String _ordenacao = '';
  final _referenciasController = TextEditingController();

  static const _opcoesOrdenacao = [
    ('', 'Padrão'),
    ('referencia', 'Referência'),
    ('quantidadeDaDivergencia', 'Divergência'),
  ];

  @override
  void dispose() {
    _referenciasController.dispose();
    super.dispose();
  }

  void _aplicarFiltros() {
    final ref = _referenciasController.text.trim();
    context.read<BalancoItensBloc>().add(
      CarregarItensDoBalancoEvent(
        balancoId: widget.balancoId,
        comDivergencia: _comDivergencia,
        referencias: ref.isEmpty ? null : [ref],
        ordenacao: _ordenacao.isEmpty ? null : [_ordenacao],
      ),
    );
  }

  void _limparFiltros() {
    setState(() {
      _comDivergencia = null;
      _ordenacao = '';
      _referenciasController.clear();
    });
    context.read<BalancoItensBloc>().add(
      CarregarItensDoBalancoEvent(balancoId: widget.balancoId),
    );
  }

  bool get _temFiltroAtivo =>
      _comDivergencia != null || _ordenacao.isNotEmpty || _referenciasController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FiltrosItensPanel(
          comDivergencia: _comDivergencia,
          ordenacao: _ordenacao,
          referenciasController: _referenciasController,
          opcoesOrdenacao: _opcoesOrdenacao,
          temFiltroAtivo: _temFiltroAtivo,
          onComDivergenciaChanged: (v) {
            setState(() => _comDivergencia = v);
            _aplicarFiltros();
          },
          onOrdenacaoChanged: (v) {
            setState(() => _ordenacao = v ?? '');
            _aplicarFiltros();
          },
          onAplicar: _aplicarFiltros,
          onLimpar: _limparFiltros,
        ),
        Expanded(
          child: BlocBuilder<BalancoItensBloc, BalancoItensState>(
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
                        onPressed: _aplicarFiltros,
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
                        if (widget.balancoEmAndamento) ...[
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              await Navigator.of(context).pushNamed(
                                EstoqueRoutes.adicionarItensBalanco,
                                arguments: {'balancoId': widget.balancoId},
                              );
                              // ignore: use_build_context_synchronously
                              _aplicarFiltros();
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
                      balancoId: widget.balancoId,
                      balancoEmAndamento: widget.balancoEmAndamento,
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
                      onPressed: _aplicarFiltros,
                      child: const Text('Atualizar itens'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FiltrosItensPanel extends StatelessWidget {
  final bool? comDivergencia;
  final String ordenacao;
  final TextEditingController referenciasController;
  final List<(String, String)> opcoesOrdenacao;
  final bool temFiltroAtivo;
  final ValueChanged<bool?> onComDivergenciaChanged;
  final ValueChanged<String?> onOrdenacaoChanged;
  final VoidCallback onAplicar;
  final VoidCallback onLimpar;

  const _FiltrosItensPanel({
    required this.comDivergencia,
    required this.ordenacao,
    required this.referenciasController,
    required this.opcoesOrdenacao,
    required this.temFiltroAtivo,
    required this.onComDivergenciaChanged,
    required this.onOrdenacaoChanged,
    required this.onAplicar,
    required this.onLimpar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.filter_list, size: 16),
                const SizedBox(width: 6),
                Text('Filtros', style: Theme.of(context).textTheme.labelLarge),
                const Spacer(),
                if (temFiltroAtivo)
                  TextButton(
                    onPressed: onLimpar,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Limpar'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: referenciasController,
              decoration: InputDecoration(
                labelText: 'Código da referência',
                border: const OutlineInputBorder(),
                isDense: true,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, size: 18),
                  onPressed: onAplicar,
                ),
              ),
              onSubmitted: (_) => onAplicar(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownMenu<String>(
                    initialSelection: ordenacao.isEmpty ? '' : ordenacao,
                    label: const Text('Ordenação'),
                    expandedInsets: EdgeInsets.zero,
                    onSelected: onOrdenacaoChanged,
                    dropdownMenuEntries: opcoesOrdenacao
                        .map((o) => DropdownMenuEntry(value: o.$1, label: o.$2))
                        .toList(),
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Com divergência'),
                  selected: comDivergencia == true,
                  onSelected: (v) => onComDivergenciaChanged(v ? true : null),
                ),
              ],
            ),
          ],
        ),
      ),
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

          return Stack(
            children: [
              ListView.builder(
                padding: EdgeInsets.only(bottom: balancoEmAndamento ? 80 : 24),
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
              ),
              if (balancoEmAndamento)
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton.extended(
                    heroTag: 'criar_lote_fab',
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
                    icon: const Icon(Icons.add),
                    label: const Text('Novo Lote'),
                  ),
                ),
            ],
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
    if (item.referencia?.trim().isNotEmpty ?? false) detalhesProduto.add('Ref: ${item.referencia!.trim()}');
    if (item.cor?.trim().isNotEmpty ?? false) detalhesProduto.add(item.cor!.trim());
    if (item.tamanho?.trim().isNotEmpty ?? false) detalhesProduto.add(item.tamanho!.trim());

    final divergencia = item.quantidadeContada - item.quantidadeOriginal;
    final temDivergencia = divergencia != 0;
    final corDivergencia = divergencia > 0 ? Colors.orange : Colors.red;
    final corCard = temDivergencia ? corDivergencia : Colors.blue;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: temDivergencia ? corDivergencia.withOpacity(0.3) : Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(width: 4, color: corCard.withOpacity(temDivergencia ? 0.8 : 0.4)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: corCard.withOpacity(0.12),
                      child: Icon(Icons.inventory_2_outlined, color: corCard, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tituloProduto,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (detalhesProduto.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              detalhesProduto.join(' • '),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _MetricaBadge(label: 'Original', valor: item.quantidadeOriginal),
                              const SizedBox(width: 6),
                              _MetricaBadge(label: 'Contada', valor: item.quantidadeContada, destaque: temDivergencia),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (temDivergencia)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: corDivergencia.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: corDivergencia.withOpacity(0.4)),
                            ),
                            child: Text(
                              '${divergencia > 0 ? '+' : ''}${divergencia.toStringAsFixed(0)}',
                              style: TextStyle(color: corDivergencia, fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ),
                        if (balancoEmAndamento) ...[
                          if (temDivergencia) const SizedBox(height: 4),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              context.read<BalancoItensBloc>().add(
                                RemoverItemDoBalancoItensEvent(
                                  balancoId: balancoId,
                                  produtoId: item.produtoId,
                                ),
                              );
                            },
                          ),
                        ],
                      ],
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

class _MetricaBadge extends StatelessWidget {
  final String label;
  final double valor;
  final bool destaque;

  const _MetricaBadge({required this.label, required this.valor, this.destaque = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: destaque ? Colors.orange.withOpacity(0.08) : Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodySmall,
          children: [
            TextSpan(text: '$label: ', style: TextStyle(color: Colors.grey.shade600)),
            TextSpan(
              text: valor.toStringAsFixed(2),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: destaque ? Colors.orange.shade700 : Colors.grey.shade800,
              ),
            ),
          ],
        ),
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
    final cor = lote.ativo ? Colors.green : Colors.red;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 4, color: cor.withOpacity(0.7)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: cor.withOpacity(0.12),
                        child: Icon(Icons.layers_outlined, color: cor, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lote.lote,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.circle, size: 8, color: cor),
                                const SizedBox(width: 4),
                                Text(
                                  lote.ativo ? 'Ativo' : 'Cancelado',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cor),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (balancoEmAndamento && lote.ativo)
                        IconButton(
                          tooltip: 'Cancelar lote',
                          icon: Icon(Icons.close, color: Colors.red.shade400, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: onCancelar,
                        ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
