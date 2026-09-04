import 'package:comercial/presentation/blocs/ecommerce_referencias_bloc/ecommerce_referencias_bloc.dart';
import 'package:comercial/presentation/pages/ecommerce_referencia_detalhe_page.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:produtos/presentantion/widgets/categoria_seletor.dart';
import 'package:produtos/presentantion/widgets/referencia_seletor.dart';

class EcommerceReferenciasPage extends StatefulWidget {
  final int ecommerceId;

  const EcommerceReferenciasPage({super.key, required this.ecommerceId});

  @override
  State<EcommerceReferenciasPage> createState() =>
      _EcommerceReferenciasPageState();
}

class _EcommerceReferenciasPageState extends State<EcommerceReferenciasPage> {
  late final EcommerceReferenciasBloc _bloc;
  final _buscaController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 350);

  List<int> _categoriaIds = [];
  bool? _rascunhoFiltro;

  bool _modoSelecao = false;
  final Set<int> _idsSelecionados = {};

  @override
  void initState() {
    super.initState();
    _bloc = sl<EcommerceReferenciasBloc>()
      ..add(EcommerceReferenciasIniciou(ecommerceId: widget.ecommerceId));
  }

  @override
  void dispose() {
    _buscaController.dispose();
    _debouncer.cancel();
    _bloc.close();
    super.dispose();
  }

  void _onBuscaAlterada(String valor) {
    _debouncer.run(() => _recarregar(busca: valor.trim()));
  }

  void _recarregar({String? busca}) {
    _bloc.add(
      EcommerceReferenciasIniciou(
        ecommerceId: widget.ecommerceId,
        busca: (busca ?? _buscaController.text.trim()).isEmpty
            ? null
            : (busca ?? _buscaController.text.trim()),
        categoriaIds: _categoriaIds.isEmpty ? null : _categoriaIds,
        rascunhoFiltro: _rascunhoFiltro,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EcommerceReferenciasBloc>.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Produtos no site'),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              tooltip: 'Filtrar por categoria',
              onPressed: () => _abrirFiltroCategoria(context),
            ),
            IconButton(
              icon: Icon(_modoSelecao ? Icons.close : Icons.checklist),
              tooltip: _modoSelecao ? 'Cancelar seleção' : 'Selecionar',
              onPressed: () => setState(() {
                _modoSelecao = !_modoSelecao;
                _idsSelecionados.clear();
              }),
            ),
            IconButton(
              icon: const Icon(Icons.visibility_off_outlined),
              tooltip: 'Despublicar todas',
              onPressed: () => _despublicarTodas(context),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(104),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                children: [
                  TextField(
                    controller: _buscaController,
                    onChanged: _onBuscaAlterada,
                    decoration: InputDecoration(
                      hintText: 'Buscar referência...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      isDense: true,
                      suffixIcon: _buscaController.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                _buscaController.clear();
                                _recarregar(busca: '');
                                setState(() {});
                              },
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: _onBuscaAlterada,
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<bool?>(
                    segments: const [
                      ButtonSegment(value: null, label: Text('Todos')),
                      ButtonSegment(value: false, label: Text('Publicados')),
                      ButtonSegment(value: true, label: Text('Rascunho')),
                    ],
                    selected: {_rascunhoFiltro},
                    onSelectionChanged: (selecao) {
                      setState(() => _rascunhoFiltro = selecao.first);
                      _recarregar();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: _modoSelecao
            ? null
            : Builder(
                builder: (context) => FloatingActionButton.extended(
                  onPressed: () => _adicionarReferencias(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar referências'),
                ),
              ),
        body: BlocListener<EcommerceReferenciasBloc, EcommerceReferenciasState>(
          listener: (context, state) {
            if (state is EcommerceReferenciasLoteConcluiu) {
              setState(() {
                _modoSelecao = false;
                _idsSelecionados.clear();
              });
              final mensagem = state.falharam == 0
                  ? '${state.publicados} referência(s) atualizada(s).'
                  : '${state.publicados} publicados, ${state.falharam} falharam.';
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(mensagem)));
            }
          },
          child: BlocBuilder<EcommerceReferenciasBloc, EcommerceReferenciasState>(
            builder: (context, state) {
              if (state is EcommerceReferenciasCarregarEmProgresso ||
                  state is EcommerceReferenciasInitial) {
                return const Center(child: CircularProgressIndicator.adaptive());
              }

              if (state is EcommerceReferenciasCarregarFalha) {
                return const Center(
                  child: Text('Não foi possível carregar as referências.'),
                );
              }

              if (state.referencias.isEmpty) {
                return Center(
                  child: Text(
                    (state.busca ?? '').isEmpty
                        ? 'Nenhuma referência vinculada ao e-commerce.'
                        : 'Nenhuma referência encontrada pra "${state.busca}".',
                  ),
                );
              }

              return Column(
                children: [
                  if (state.processandoLote)
                    Column(
                      children: [
                        const LinearProgressIndicator(),
                        if (state.loteTotal != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              'Processando ${state.loteAtual} de ${state.loteTotal}...',
                            ),
                          ),
                      ],
                    ),
                  Expanded(child: _buildLista(context, state)),
                  if (_modoSelecao) _buildBarraSelecao(context, state),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLista(BuildContext context, EcommerceReferenciasState state) {
    return ListView.builder(
      itemCount: state.referencias.length,
      itemBuilder: (context, index) {
        final referencia = state.referencias[index];
        final selecionado =
            referencia.id != null && _idsSelecionados.contains(referencia.id);
        return ListTile(
          leading: _modoSelecao
              ? Checkbox(
                  value: selecionado,
                  onChanged: referencia.id == null
                      ? null
                      : (_) => _alternarSelecao(referencia.id!),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: referencia.imagemUrl != null
                        ? Image.network(
                            referencia.imagemUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _placeholderImagem(context),
                          )
                        : _placeholderImagem(context),
                  ),
                ),
          title: Text(
            referencia.referenciaNome ??
                'Referência #${referencia.referenciaId}',
          ),
          subtitle: Text(
            '${referencia.valor != null ? _formatarMoeda(referencia.valor!) : 'Sem preço'} • Estoque: ${referencia.saldo ?? 0}',
          ),
          trailing: _modoSelecao
              ? Chip(
                  label: Text(referencia.rascunho ? 'Rascunho' : 'Publicado'),
                  backgroundColor: referencia.rascunho
                      ? Colors.orange.withValues(alpha: 0.2)
                      : Colors.green.withValues(alpha: 0.2),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        referencia.rascunho
                            ? Icons.publish_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      tooltip: referencia.rascunho ? 'Publicar' : 'Despublicar',
                      color: referencia.rascunho ? Colors.green : Colors.orange,
                      onPressed: state.processandoLote
                          ? null
                          : () => _bloc.add(
                                EcommerceReferenciaPublicarSolicitou(
                                  ecommerceId: widget.ecommerceId,
                                  referenciaEcommerceId: referencia.id!,
                                  rascunho: !referencia.rascunho,
                                ),
                              ),
                    ),
                    Chip(
                      label: Text(referencia.rascunho ? 'Rascunho' : 'Publicado'),
                      backgroundColor: referencia.rascunho
                          ? Colors.orange.withValues(alpha: 0.2)
                          : Colors.green.withValues(alpha: 0.2),
                    ),
                  ],
                ),
          onTap: _modoSelecao
              ? (referencia.id == null
                  ? null
                  : () => _alternarSelecao(referencia.id!))
              : () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => EcommerceReferenciaDetalhePage(
                        ecommerceId: widget.ecommerceId,
                        referencia: referencia,
                      ),
                    ),
                  );
                  _recarregar();
                },
        );
      },
    );
  }

  Widget _buildBarraSelecao(BuildContext context, EcommerceReferenciasState state) {
    final idsFiltrados = state.referencias
        .map((referencia) => referencia.id)
        .whereType<int>()
        .toList();
    final todosSelecionados = idsFiltrados.isNotEmpty &&
        idsFiltrados.every(_idsSelecionados.contains);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('${_idsSelecionados.length} selecionado(s)'),
                const Spacer(),
                TextButton(
                  onPressed: state.processandoLote
                      ? null
                      : () => setState(() {
                            if (todosSelecionados) {
                              _idsSelecionados.removeAll(idsFiltrados);
                            } else {
                              _idsSelecionados.addAll(idsFiltrados);
                            }
                          }),
                  child: Text(
                    todosSelecionados
                        ? 'Limpar seleção'
                        : 'Selecionar todos (${idsFiltrados.length})',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: state.processandoLote
                        ? null
                        : () => setState(() {
                              _modoSelecao = false;
                              _idsSelecionados.clear();
                            }),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _idsSelecionados.isEmpty || state.processandoLote
                        ? null
                        : () => _bloc.add(
                              EcommerceReferenciasPublicarEmLoteSolicitou(
                                ecommerceId: widget.ecommerceId,
                                referenciaEcommerceIds:
                                    _idsSelecionados.toList(),
                                rascunho: true,
                              ),
                            ),
                    child: const Text('Despublicar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: _idsSelecionados.isEmpty || state.processandoLote
                        ? null
                        : () => _bloc.add(
                              EcommerceReferenciasPublicarEmLoteSolicitou(
                                ecommerceId: widget.ecommerceId,
                                referenciaEcommerceIds:
                                    _idsSelecionados.toList(),
                                rascunho: false,
                              ),
                            ),
                    child: const Text('Publicar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _alternarSelecao(int id) {
    setState(() {
      if (!_idsSelecionados.remove(id)) {
        _idsSelecionados.add(id);
      }
    });
  }

  Future<void> _abrirFiltroCategoria(BuildContext context) async {
    var selecionadas = List<int>.from(_categoriaIds);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (dialogContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(dialogContext).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CategoriaSeletor(
                modo: CategoriaSeletorModo.multipla,
                titulo: 'Filtrar por categoria',
                idCategoriasSelecionadasIniciais: _categoriaIds,
                onCategoriaChanged: (categorias) {
                  selecionadas = categorias
                      .map((categoria) => categoria.id)
                      .whereType<int>()
                      .toList();
                },
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  setState(() => _categoriaIds = selecionadas);
                  _recarregar();
                },
                child: const Text('Aplicar'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _adicionarReferencias(BuildContext context) async {
    List<int> idsSelecionados = [];

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (dialogContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(dialogContext).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ReferenciaSeletor(
                modo: ReferenciaSeletorModo.multipla,
                permitirCadastro: false,
                onReferenciaChanged: (selecionadas) {
                  idsSelecionados = selecionadas
                      .map((referencia) => referencia.id)
                      .whereType<int>()
                      .toList();
                },
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  for (final referenciaId in idsSelecionados) {
                    _bloc.add(
                      EcommerceReferenciaAdicionou(
                        ecommerceId: widget.ecommerceId,
                        referenciaId: referenciaId,
                      ),
                    );
                  }
                },
                child: const Text('Adicionar'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _despublicarTodas(BuildContext context) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Despublicar todas as referências'),
          content: const Text(
            'Todas as referências publicadas deste e-commerce vão sair do '
            'site imediatamente. Essa ação pode ser desfeita depois, '
            'republicando cada referência.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Despublicar todas'),
            ),
          ],
        );
      },
    );

    if (confirmou == true) {
      _bloc.add(
        EcommerceReferenciasDespublicarTodasSolicitou(
          ecommerceId: widget.ecommerceId,
        ),
      );
    }
  }

  Widget _placeholderImagem(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  String _formatarMoeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}
