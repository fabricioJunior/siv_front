import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/seletores.dart';
import 'package:core/sessao.dart';
import 'package:estoque/domain/models/filtro_produto_do_estoque.dart';
import 'package:estoque/domain/models/preco_referencia_estoque.dart';
import 'package:estoque/presentation.dart';
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

  List<int> _corIds = const [];
  List<int> _tamanhoIds = const [];
  FiltroDisponibilidadeEstoque _disponibilidadeEstoque =
      FiltroDisponibilidadeEstoque.todos;
  DateTime? _atualizadoEmInicio;
  DateTime? _atualizadoEmFim;
  SelectData? _tabelaDePrecoSelecionada;
  bool _gerandoRelatorio = false;
  bool _filtrosExpandidos = false;
  CampoOrdenacaoEstoque? _ordenarPor;
  DirecaoOrdenacaoEstoque _ordenarDirecao = DirecaoOrdenacaoEstoque.asc;

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
        corIds: _corIds,
        tamanhoIds: _tamanhoIds,
        disponibilidadeEstoque: _disponibilidadeEstoque,
        atualizadoEmInicio: _atualizadoEmInicio,
        atualizadoEmFim: _atualizadoEmFim,
        ordenarPor: _ordenarPor,
        ordenarDirecao: _ordenarDirecao,
      ),
    );
  }

  int get _quantidadeFiltrosAtivos {
    var total = 0;
    if (_disponibilidadeEstoque != FiltroDisponibilidadeEstoque.todos) total++;
    if (_atualizadoEmInicio != null || _atualizadoEmFim != null) total++;
    if (_corIds.isNotEmpty) total++;
    if (_tamanhoIds.isNotEmpty) total++;
    if (_tabelaDePrecoSelecionada != null) total++;
    return total;
  }

  String _rotuloCampoOrdenacao(CampoOrdenacaoEstoque campo) {
    switch (campo) {
      case CampoOrdenacaoEstoque.nome:
        return 'Nome';
      case CampoOrdenacaoEstoque.saldo:
        return 'Saldo';
      case CampoOrdenacaoEstoque.referenciaIdExterno:
        return 'Referência';
      case CampoOrdenacaoEstoque.atualizadoEm:
        return 'Atualizado em';
    }
  }

  Future<void> _selecionarPeriodoAtualizacao() async {
    final intervaloSelecionado = await showDateRangePicker(
      context: context,
      initialDateRange: _atualizadoEmInicio != null && _atualizadoEmFim != null
          ? DateTimeRange(start: _atualizadoEmInicio!, end: _atualizadoEmFim!)
          : null,
      currentDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      helpText: 'Filtrar por período de atualização',
    );

    if (!mounted || intervaloSelecionado == null) return;
    setState(() {
      _atualizadoEmInicio = intervaloSelecionado.start;
      _atualizadoEmFim = intervaloSelecionado.end;
    });
    _recarregar();
  }

  Future<void> _gerarRelatorioValorEstoque() async {
    final tabelaSelecionada = _tabelaDePrecoSelecionada;
    if (tabelaSelecionada == null || _gerandoRelatorio) return;

    setState(() => _gerandoRelatorio = true);
    try {
      final itens = await _bloc.carregarTodosOsItensParaRelatorio();
      final precos = await widget.obterPrecosDaTabela(tabelaSelecionada.id);
      await EstoqueRelatorioPdfExporter.exportarValorEstoque(
        itens: itens,
        precos: precos,
        tabelaDePrecoNome: tabelaSelecionada.nome,
      );
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
            appBar: AppBar(title: const Text('Saldo de Estoque')),
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
                            onPressed: () => setState(
                              () => _filtrosExpandidos = !_filtrosExpandidos,
                            ),
                            icon: Badge(
                              isLabelVisible: _quantidadeFiltrosAtivos > 0,
                              label: Text('$_quantidadeFiltrosAtivos'),
                              child: const Icon(Icons.filter_list),
                            ),
                            label: Text(
                              _filtrosExpandidos
                                  ? 'Ocultar filtros'
                                  : 'Filtros',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildOrdenacao(context),
                      ],
                    ),
                    if (_filtrosExpandidos) ...[
                      const SizedBox(height: 12),
                      _buildPainelFiltros(context),
                    ],
                    const SizedBox(height: 8),
                    Expanded(
                      child: BlocBuilder<EstoqueSaldoBloc, EstoqueSaldoState>(
                        builder: (context, state) {
                          if (state.step == EstoqueSaldoStep.carregando &&
                              state.itens.isEmpty) {
                            return const Center(
                              child: CircularProgressIndicator.adaptive(),
                            );
                          }

                          if (state.step == EstoqueSaldoStep.falha &&
                              state.itens.isEmpty) {
                            return Center(
                              child: Text(
                                state.erro ?? 'Erro ao carregar estoque.',
                              ),
                            );
                          }

                          if (state.itens.isEmpty) {
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

                          final quantidadeTotal = state.itens.fold<double>(
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
                                        label: 'Produtos carregados',
                                        valor: '${state.itens.length}',
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
                                      state.itens.length +
                                      (exibirLoaderFinal ? 1 : 0),
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    if (index >= state.itens.length) {
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

                                    final item = state.itens[index];
                                    final unidadeMedida =
                                        item.unidadeMedida?.trim().isNotEmpty ==
                                            true
                                        ? item.unidadeMedida!
                                        : '-';
                                    return Card(
                                      child: ListTile(
                                        title: Text(item.nome),
                                        subtitle: Text(
                                          'Referência: ${item.referenciaId}  |  Produto: ${item.produtoIdExterno}\nCor: ${item.corNome}  •  Tam: ${item.tamanhoNome}  •  UM: $unidadeMedida',
                                        ),
                                        trailing: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              item.saldo.round().toString(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                            Text(
                                              'Atualizado: ${_formatDate(item.atualizadoEm)}',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),
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

  Widget _buildOrdenacao(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PopupMenuButton<CampoOrdenacaoEstoque>(
          tooltip: 'Ordenar por',
          initialValue: _ordenarPor,
          onSelected: (campo) {
            setState(() => _ordenarPor = campo);
            _recarregar();
          },
          itemBuilder: (context) => CampoOrdenacaoEstoque.values
              .map(
                (campo) => PopupMenuItem(
                  value: campo,
                  child: Text(_rotuloCampoOrdenacao(campo)),
                ),
              )
              .toList(),
          child: Chip(
            label: Text(
              _ordenarPor == null
                  ? 'Ordenar'
                  : _rotuloCampoOrdenacao(_ordenarPor!),
            ),
            avatar: const Icon(Icons.sort, size: 18),
          ),
        ),
        if (_ordenarPor != null)
          IconButton(
            tooltip: _ordenarDirecao == DirecaoOrdenacaoEstoque.asc
                ? 'Crescente'
                : 'Decrescente',
            icon: Icon(
              _ordenarDirecao == DirecaoOrdenacaoEstoque.asc
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
            ),
            onPressed: () {
              setState(() {
                _ordenarDirecao = _ordenarDirecao == DirecaoOrdenacaoEstoque.asc
                    ? DirecaoOrdenacaoEstoque.desc
                    : DirecaoOrdenacaoEstoque.asc;
              });
              _recarregar();
            },
          ),
      ],
    );
  }

  Widget _buildPainelFiltros(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Todos'),
                  selected:
                      _disponibilidadeEstoque ==
                      FiltroDisponibilidadeEstoque.todos,
                  onSelected: (_) {
                    setState(() {
                      _disponibilidadeEstoque =
                          FiltroDisponibilidadeEstoque.todos;
                    });
                    _recarregar();
                  },
                ),
                ChoiceChip(
                  label: const Text('Com estoque'),
                  selected:
                      _disponibilidadeEstoque ==
                      FiltroDisponibilidadeEstoque.comEstoque,
                  onSelected: (_) {
                    setState(() {
                      _disponibilidadeEstoque =
                          FiltroDisponibilidadeEstoque.comEstoque;
                    });
                    _recarregar();
                  },
                ),
                ChoiceChip(
                  label: const Text('Sem estoque'),
                  selected:
                      _disponibilidadeEstoque ==
                      FiltroDisponibilidadeEstoque.semEstoque,
                  onSelected: (_) {
                    setState(() {
                      _disponibilidadeEstoque =
                          FiltroDisponibilidadeEstoque.semEstoque;
                    });
                    _recarregar();
                  },
                ),
                OutlinedButton.icon(
                  onPressed: _selecionarPeriodoAtualizacao,
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: Text(
                    _atualizadoEmInicio == null || _atualizadoEmFim == null
                        ? 'Atualizado em (intervalo)'
                        : 'Atualizado: ${_formatDateOnly(_atualizadoEmInicio!)} - ${_formatDateOnly(_atualizadoEmFim!)}',
                  ),
                ),
                if (_atualizadoEmInicio != null || _atualizadoEmFim != null)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _atualizadoEmInicio = null;
                        _atualizadoEmFim = null;
                      });
                      _recarregar();
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Limpar data'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            widget.seletorCores.call(
              onChanged: (dados) {
                _corIds = dados.map((e) => e.id).toList();
                _recarregar();
              },
            ),
            const SizedBox(height: 12),
            widget.seletorTamanhos.call(
              onChanged: (dados) {
                _tamanhoIds = dados.map((e) => e.id).toList();
                _recarregar();
              },
            ),
            const SizedBox(height: 12),
            widget.seletorTabelaPreco.call(
              onChanged: (dados) {
                setState(() {
                  _tabelaDePrecoSelecionada = dados.isEmpty
                      ? null
                      : dados.first;
                });
              },
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _tabelaDePrecoSelecionada == null || _gerandoRelatorio
                    ? null
                    : _gerarRelatorioValorEstoque,
                icon: _gerandoRelatorio
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.picture_as_pdf_outlined),
                label: Text(
                  _gerandoRelatorio
                      ? 'Gerando relatório...'
                      : 'Gerar relatório de valor do estoque',
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
