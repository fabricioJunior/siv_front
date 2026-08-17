import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/seletores.dart';
import 'package:core/sessao.dart';
import 'package:estoque/domain/models/filtro_produto_do_estoque.dart';
import 'package:estoque/domain/models/preco_referencia_estoque.dart';
import 'package:estoque/domain/models/produto_do_estoque.dart';
import 'package:estoque/domain/models/produto_do_estoque_por_referencia.dart';
import 'package:estoque/presentation.dart';
import 'package:estoque/presentation/relatorios/csv/estoque_relatorio_csv_exporter.dart';
import 'package:estoque/presentation/relatorios/pdf/estoque_relatorio_pdf_exporter.dart';
import 'package:flutter/material.dart';

typedef ObterPrecosDaTabela =
    Future<List<PrecoReferenciaEstoque>> Function(int tabelaDePrecoId);

class EstoqueSaldoPage extends StatefulWidget {
  final SeletorWidget seletorCores;
  final SeletorWidget seletorTamanhos;
  final SeletorWidget seletorTabelaPreco;
  final ObterPrecosDaTabela obterPrecosDaTabela;

  const EstoqueSaldoPage({
    super.key,
    required this.seletorCores,
    required this.seletorTamanhos,
    required this.seletorTabelaPreco,
    required this.obterPrecosDaTabela,
  });

  @override
  State<EstoqueSaldoPage> createState() => _EstoqueSaldoPageState();
}

class _EstoqueSaldoPageState extends State<EstoqueSaldoPage> {
  late final EstoqueSaldoBloc _bloc;
  final Debouncer _debouncer = Debouncer(milliseconds: 400);
  final TextEditingController _buscaController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final StreamSubscription<List<SelectData>>? _corSub;
  late final StreamSubscription<List<SelectData>>? _tamanhoSub;

  List<SelectData> _coresSelecionadas = const [];
  List<SelectData> _tamanhosSelecionados = const [];
  FiltroDisponibilidadeEstoque _disponibilidadeEstoque =
      FiltroDisponibilidadeEstoque.todos;
  DateTime? _atualizadoEmInicio;
  DateTime? _atualizadoEmFim;
  SelectData? _tabelaDePrecoSelecionada;
  bool _gerandoRelatorio = false;
  bool _exportandoCsv = false;
  bool _visualizarPorReferencia = false;
  List<OrdenacaoEstoqueItem> _ordenacoes = const [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _bloc = sl<EstoqueSaldoBloc>()..add(const EstoqueSaldoIniciou());
  }

  @override
  void dispose() {
    _corSub?.cancel();
    _tamanhoSub?.cancel();
    _buscaController.dispose();
    _scrollController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _recarregar() {
    _bloc.add(
      EstoqueSaldoIniciou(
        termoBusca: _buscaController.text.trim(),
        corIds: _coresSelecionadas.map((e) => e.id).toList(),
        tamanhoIds: _tamanhosSelecionados.map((e) => e.id).toList(),
        disponibilidadeEstoque: _disponibilidadeEstoque,
        atualizadoEmInicio: _atualizadoEmInicio,
        atualizadoEmFim: _atualizadoEmFim,
        ordenacoes: _ordenacoes,
        visualizarPorReferencia: _visualizarPorReferencia,
      ),
    );
  }

  void _reiniciarListaERecarregar() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    _recarregar();
  }

  int get _quantidadeFiltrosAtivos {
    var total = 0;
    if (_disponibilidadeEstoque != FiltroDisponibilidadeEstoque.todos) total++;
    if (_atualizadoEmInicio != null || _atualizadoEmFim != null) total++;
    if (_coresSelecionadas.isNotEmpty) total++;
    if (_tamanhosSelecionados.isNotEmpty) total++;
    if (_tabelaDePrecoSelecionada != null) total++;
    return total;
  }

  String _rotuloCampoOrdenacao(CampoOrdenacaoEstoque campo) {
    switch (campo) {
      case CampoOrdenacaoEstoque.nome:
        return 'Nome';
      case CampoOrdenacaoEstoque.saldo:
        return 'Quantidade em estoque';
      case CampoOrdenacaoEstoque.referenciaIdExterno:
        return 'Referência';
      case CampoOrdenacaoEstoque.atualizadoEm:
        return 'Atualizado em';
      case CampoOrdenacaoEstoque.corNome:
        return 'Cor';
      case CampoOrdenacaoEstoque.tamanhoNome:
        return 'Tamanho';
    }
  }

  Future<void> _gerarRelatorioValorEstoque() async {
    final tabelaSelecionada = _tabelaDePrecoSelecionada;
    if (tabelaSelecionada == null || _gerandoRelatorio) return;

    setState(() => _gerandoRelatorio = true);
    try {
      final precos = await widget.obterPrecosDaTabela(tabelaSelecionada.id);
      if (_visualizarPorReferencia) {
        final itens = await _bloc.carregarTodosOsItensAgrupadosParaRelatorio();
        await EstoqueRelatorioPdfExporter.exportarValorEstoquePorReferencia(
          itens: itens,
          precos: precos,
          tabelaDePrecoNome: tabelaSelecionada.nome,
        );
      } else {
        final itens = await _bloc.carregarTodosOsItensParaRelatorio();
        await EstoqueRelatorioPdfExporter.exportarValorEstoque(
          itens: itens,
          precos: precos,
          tabelaDePrecoNome: tabelaSelecionada.nome,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao gerar relatório de valor do estoque.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _gerandoRelatorio = false);
    }
  }

  Future<void> _exportarCsv() async {
    if (_exportandoCsv) return;
    setState(() => _exportandoCsv = true);
    try {
      final String? caminho;
      if (_visualizarPorReferencia) {
        final itens = await _bloc.carregarTodosOsItensAgrupadosParaRelatorio();
        caminho = await EstoqueRelatorioCsvExporter.exportarPorReferencia(itens);
      } else {
        final itens = await _bloc.carregarTodosOsItensParaRelatorio();
        caminho = await EstoqueRelatorioCsvExporter.exportarPorProduto(itens);
      }
      if (!mounted) return;
      if (caminho != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Relatório salvo em $caminho')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao exportar: $e')),
      );
    } finally {
      if (mounted) setState(() => _exportandoCsv = false);
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final state = _bloc.state;
    if (state.step == EstoqueSaldoStep.carregando ||
        state.step == EstoqueSaldoStep.carregandoMais ||
        state.sincronizando ||
        !state.temMaisPaginas) {
      return;
    }

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _bloc.add(const EstoqueSaldoCarregarMaisSolicitado());
    }
  }

  @override
  Widget build(BuildContext context) {
    var commonData = sl<IAcessoGlobalSessao>();
    return StreamBuilder<bool>(
      initialData: commonData.dadosSincronizados,
      stream: commonData.sincronizandoDados,
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.data == true) {
          return Scaffold(
            appBar: AppBar(title: const Text('Saldo de Estoque')),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator.adaptive(),
                  SizedBox(height: 12),
                  Text(
                    'Os dados do estoque ainda estão sendo sincronizados. Por favor, aguarde.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        return BlocProvider<EstoqueSaldoBloc>.value(
          value: _bloc,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Saldo de Estoque'),
              actions: [
                IconButton(
                  tooltip: 'Exportar para Excel',
                  onPressed: _exportandoCsv ? null : _exportarCsv,
                  icon: _exportandoCsv
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.file_download_outlined),
                ),
                IconButton(
                  tooltip: 'Gerar relatório de valor do estoque',
                  onPressed:
                      _tabelaDePrecoSelecionada == null || _gerandoRelatorio
                      ? null
                      : _gerarRelatorioValorEstoque,
                  icon: _gerandoRelatorio
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.picture_as_pdf_outlined),
                ),
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SearchBar(
                      controller: _buscaController,
                      hintText:
                          'Buscar por nome, produto externo ou referência externa',
                      onChanged: (_) => _debouncer.run(_recarregar),
                      onSubmitted: (_) => _recarregar(),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _abrirFiltros,
                            icon: Badge(
                              isLabelVisible: _quantidadeFiltrosAtivos > 0,
                              label: Text('$_quantidadeFiltrosAtivos'),
                              child: const Icon(Icons.filter_list),
                            ),
                            label: const Text('Filtros'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildOrdenacao(context),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(
                            value: false,
                            label: Text('Por produto'),
                            icon: Icon(Icons.checkroom_outlined, size: 16),
                          ),
                          ButtonSegment(
                            value: true,
                            label: Text('Por referência'),
                            icon: Icon(Icons.style_outlined, size: 16),
                          ),
                        ],
                        selected: {_visualizarPorReferencia},
                        onSelectionChanged: (selecao) {
                          setState(
                            () => _visualizarPorReferencia = selecao.first,
                          );
                          _reiniciarListaERecarregar();
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: BlocBuilder<EstoqueSaldoBloc, EstoqueSaldoState>(
                        builder: (context, state) {
                          final totalCarregado = state.visualizarPorReferencia
                              ? state.itensAgrupados.length
                              : state.itens.length;

                          if (state.step == EstoqueSaldoStep.carregando &&
                              totalCarregado == 0) {
                            return const Center(
                              child: CircularProgressIndicator.adaptive(),
                            );
                          }

                          if (state.step == EstoqueSaldoStep.falha &&
                              totalCarregado == 0) {
                            return Center(
                              child: Text(
                                state.erro ?? 'Erro ao carregar estoque.',
                              ),
                            );
                          }

                          if (totalCarregado == 0) {
                            if (state.sincronizando) {
                              return Center(
                                child: _buildSincronizando(context),
                              );
                            }

                            return const Center(
                              child: Text(
                                'Nenhum item encontrado para os filtros informados.',
                              ),
                            );
                          }

                          final exibirLoaderFinal =
                              state.step == EstoqueSaldoStep.carregandoMais;

                          final quantidadeTotal = state.visualizarPorReferencia
                              ? state.itensAgrupados.fold<double>(
                                  0,
                                  (soma, item) => soma + item.saldoTotal,
                                )
                              : state.itens.fold<double>(
                                  0,
                                  (soma, item) => soma + item.saldo,
                                );

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Card(
                                margin: EdgeInsets.zero,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: 24,
                                    runSpacing: 8,
                                    children: [
                                      _buildResumo(
                                        context,
                                        label: state.visualizarPorReferencia
                                            ? 'Referências carregadas'
                                            : 'Produtos carregados',
                                        valor: '$totalCarregado',
                                      ),
                                      _buildResumo(
                                        context,
                                        label: 'Quantidade total',
                                        valor: quantidadeTotal
                                            .round()
                                            .toString(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 12,
                                runSpacing: 8,
                                children: [
                                  Text(
                                    'Total encontrado: ${state.totalItems}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelLarge,
                                  ),
                                  if (state.sincronizando)
                                    _buildSincronizando(context),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: ListView.separated(
                                  controller: _scrollController,
                                  itemCount:
                                      totalCarregado +
                                      (exibirLoaderFinal ? 1 : 0),
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    if (index >= totalCarregado) {
                                      return const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        child: Center(
                                          child:
                                              CircularProgressIndicator.adaptive(),
                                        ),
                                      );
                                    }

                                    return state.visualizarPorReferencia
                                        ? _buildLinhaReferencia(
                                            context,
                                            state.itensAgrupados[index],
                                          )
                                        : _buildLinhaProduto(
                                            context,
                                            state.itens[index],
                                          );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLinhaProduto(BuildContext context, ProdutoDoEstoque item) {
    final unidadeMedida = item.unidadeMedida?.trim().isNotEmpty == true
        ? item.unidadeMedida!
        : '-';
    return Card(
      child: ListTile(
        title: Text(item.nome),
        subtitle: Text(
          'Referência: ${item.referenciaId}  |  Produto: ${item.produtoIdExterno}\nCor: ${item.corNome}  •  Tam: ${item.tamanhoNome}  •  UM: $unidadeMedida',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              item.saldo.round().toString(),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              'Atualizado: ${_formatDate(item.atualizadoEm)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinhaReferencia(
    BuildContext context,
    ProdutoDoEstoquePorReferencia item,
  ) {
    return Card(
      child: ListTile(
        title: Text(item.nome),
        subtitle: Text(
          'Referência: ${item.referenciaIdExterno ?? item.referenciaId}  |  Variações: ${item.quantidadeVariacoes}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              item.saldoTotal.round().toString(),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              'Atualizado: ${_formatDate(item.atualizadoEm)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdenacao(BuildContext context) {
    final rotulo = _ordenacoes.isEmpty
        ? 'Ordenar'
        : _ordenacoes
              .map((item) => _rotuloCampoOrdenacao(item.campo))
              .join(', ');

    return ActionChip(
      avatar: const Icon(Icons.sort, size: 18),
      label: Text(rotulo),
      onPressed: _abrirSeletorDeOrdenacao,
    );
  }

  Future<void> _abrirSeletorDeOrdenacao() async {
    var rascunho = List<OrdenacaoEstoqueItem>.from(_ordenacoes);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final disponiveis = CampoOrdenacaoEstoque.values
                .where((campo) => !rascunho.any((item) => item.campo == campo))
                .toList(growable: false);

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ordenar por',
                    style: Theme.of(sheetContext).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Combine mais de um critério: a ordem da lista abaixo '
                    'define a prioridade (o primeiro desempata usando o '
                    'segundo, e assim por diante).',
                    style: Theme.of(sheetContext).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  if (rascunho.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('Nenhum critério selecionado.'),
                    )
                  else
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: rascunho.length,
                      onReorder: (oldIndex, newIndex) {
                        setSheetState(() {
                          if (newIndex > oldIndex) newIndex--;
                          final item = rascunho.removeAt(oldIndex);
                          rascunho.insert(newIndex, item);
                        });
                      },
                      itemBuilder: (context, index) {
                        final item = rascunho[index];
                        return ListTile(
                          key: ValueKey(item.campo),
                          leading: const Icon(Icons.drag_handle),
                          title: Text(_rotuloCampoOrdenacao(item.campo)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip:
                                    item.direcao == DirecaoOrdenacaoEstoque.asc
                                    ? 'Crescente'
                                    : 'Decrescente',
                                icon: Icon(
                                  item.direcao == DirecaoOrdenacaoEstoque.asc
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                ),
                                onPressed: () {
                                  setSheetState(() {
                                    rascunho[index] = item.copyWith(
                                      direcao:
                                          item.direcao ==
                                              DirecaoOrdenacaoEstoque.asc
                                          ? DirecaoOrdenacaoEstoque.desc
                                          : DirecaoOrdenacaoEstoque.asc,
                                    );
                                  });
                                },
                              ),
                              IconButton(
                                tooltip: 'Remover',
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  setSheetState(() => rascunho.removeAt(index));
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  if (disponiveis.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: disponiveis
                          .map(
                            (campo) => ActionChip(
                              avatar: const Icon(Icons.add, size: 16),
                              label: Text(_rotuloCampoOrdenacao(campo)),
                              onPressed: () {
                                setSheetState(
                                  () => rascunho.add(
                                    OrdenacaoEstoqueItem(campo: campo),
                                  ),
                                );
                              },
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (rascunho.isNotEmpty)
                        TextButton(
                          onPressed: () =>
                              setSheetState(() => rascunho.clear()),
                          child: const Text('Limpar'),
                        ),
                      const Spacer(),
                      FilledButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        child: const Text('Aplicar'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (!mounted) return;
    setState(() => _ordenacoes = rascunho);
    _reiniciarListaERecarregar();
  }

  Future<void> _abrirFiltros() async {
    var disponibilidade = _disponibilidadeEstoque;
    var atualizadoEmInicio = _atualizadoEmInicio;
    var atualizadoEmFim = _atualizadoEmFim;
    var coresSelecionadas = _coresSelecionadas;
    var tamanhosSelecionados = _tamanhosSelecionados;
    var tabelaSelecionada = _tabelaDePrecoSelecionada;

    final agora = DateTime.now();

    Future<void> selecionarPeriodo(
      void Function(void Function()) setSheetState,
    ) async {
      final resultado = await abrirFiltroPeriodoSheet(
        context: context,
        dataInicioAtual: atualizadoEmInicio ?? agora,
        dataFimAtual: atualizadoEmFim ?? agora,
        firstDate: DateTime(2000),
        lastDate: agora.add(const Duration(days: 3650)),
        permitirHora: false,
      );
      if (!mounted || resultado == null) return;
      setSheetState(() {
        atualizadoEmInicio = resultado.dataInicio;
        atualizadoEmFim = resultado.dataFim;
      });
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filtros',
                      style: Theme.of(sheetContext).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Todos'),
                          selected:
                              disponibilidade ==
                              FiltroDisponibilidadeEstoque.todos,
                          onSelected: (_) => setSheetState(
                            () => disponibilidade =
                                FiltroDisponibilidadeEstoque.todos,
                          ),
                        ),
                        ChoiceChip(
                          label: const Text('Com estoque'),
                          selected:
                              disponibilidade ==
                              FiltroDisponibilidadeEstoque.comEstoque,
                          onSelected: (_) => setSheetState(
                            () => disponibilidade =
                                FiltroDisponibilidadeEstoque.comEstoque,
                          ),
                        ),
                        ChoiceChip(
                          label: const Text('Sem estoque'),
                          selected:
                              disponibilidade ==
                              FiltroDisponibilidadeEstoque.semEstoque,
                          onSelected: (_) => setSheetState(
                            () => disponibilidade =
                                FiltroDisponibilidadeEstoque.semEstoque,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => selecionarPeriodo(setSheetState),
                          icon: const Icon(Icons.calendar_today_outlined),
                          label: Text(
                            atualizadoEmInicio == null ||
                                    atualizadoEmFim == null
                                ? 'Atualizado em (intervalo)'
                                : 'Atualizado: ${_formatDateOnly(atualizadoEmInicio!)} - ${_formatDateOnly(atualizadoEmFim!)}',
                          ),
                        ),
                        if (atualizadoEmInicio != null ||
                            atualizadoEmFim != null)
                          TextButton.icon(
                            onPressed: () => setSheetState(() {
                              atualizadoEmInicio = null;
                              atualizadoEmFim = null;
                            }),
                            icon: const Icon(Icons.close),
                            label: const Text('Limpar data'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    widget.seletorCores.call(
                      SeletorData(
                        itemsSelecionadosInicial: coresSelecionadas,
                        onChanged: (dados) {
                          coresSelecionadas = dados;
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    widget.seletorTamanhos.call(
                      SeletorData(
                        itemsSelecionadosInicial: tamanhosSelecionados,
                        onChanged: (dados) {
                          tamanhosSelecionados = dados;
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    widget.seletorTabelaPreco.call(
                      SeletorData(
                        itemsSelecionadosInicial: tabelaSelecionada != null
                            ? [tabelaSelecionada!]
                            : null,
                        onChanged: (dados) => setSheetState(
                          () => tabelaSelecionada = dados.isEmpty
                              ? null
                              : dados.first,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: const Text('Aplicar'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (!mounted) return;
    setState(() {
      _disponibilidadeEstoque = disponibilidade;
      _atualizadoEmInicio = atualizadoEmInicio;
      _atualizadoEmFim = atualizadoEmFim;
      _coresSelecionadas = coresSelecionadas;
      _tamanhosSelecionados = tamanhosSelecionados;
      _tabelaDePrecoSelecionada = tabelaSelecionada;
    });
    _reiniciarListaERecarregar();
  }

  Widget _buildResumo(
    BuildContext context, {
    required String label,
    required String valor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          valor,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildSincronizando(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 8),
        Text('Sincronizando...', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  String _formatDate(DateTime? value) => formatarDataHora(value);

  String _formatDateOnly(DateTime value) {
    final d = value.day.toString().padLeft(2, '0');
    final m = value.month.toString().padLeft(2, '0');
    final y = value.year.toString();
    return '$d/$m/$y';
  }
}
