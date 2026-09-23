import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/seletores.dart';
import 'package:core/tema.dart';
import 'package:estoque/domain/models/filtro_historico_estoque.dart';
import 'package:estoque/domain/models/historico_estoque.dart';
import 'package:estoque/presentation.dart';
import 'package:flutter/material.dart';

/// Filtro textual (`busca`) cobre referência/produto/funcionário/cliente no
/// backend (LIKE case-insensitive, OR entre os campos). Os demais filtros
/// (operador, caixa, período) viram [FiltroChip]s abaixo da busca, seguindo o
/// padrão já usado em outras telas do projeto.
class HistoricoEstoquePage extends StatefulWidget {
  final Future<List<SelectData>> Function() obterUsuarios;
  final Future<List<SelectData>> Function() obterCaixas;

  const HistoricoEstoquePage({
    super.key,
    required this.obterUsuarios,
    required this.obterCaixas,
  });

  @override
  State<HistoricoEstoquePage> createState() => _HistoricoEstoquePageState();
}

class _HistoricoEstoquePageState extends State<HistoricoEstoquePage> {
  late final HistoricoEstoqueBloc _bloc;
  final Debouncer _debouncer = Debouncer(milliseconds: 400);
  final TextEditingController _buscaController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  SelectData? _usuarioSelecionado;
  SelectData? _caixaSelecionado;
  late DateTime _dataInicio;
  late DateTime _dataFim;
  bool _horaAjustadaManualmente = false;

  List<SelectData> _usuarios = const [];
  List<SelectData> _caixas = const [];

  @override
  void initState() {
    super.initState();
    final agora = DateTime.now();
    _dataInicio = agora.subtract(const Duration(hours: 24));
    _dataFim = agora;

    _scrollController.addListener(_onScroll);
    _bloc = sl<HistoricoEstoqueBloc>()
      ..add(HistoricoEstoqueIniciou(filtro: _montarFiltro()));

    widget.obterUsuarios().then((usuarios) {
      if (!mounted) return;
      setState(() => _usuarios = usuarios);
    });
    widget.obterCaixas().then((caixas) {
      if (!mounted) return;
      setState(() => _caixas = caixas);
    });
  }

  @override
  void dispose() {
    _buscaController.dispose();
    _scrollController.dispose();
    _bloc.close();
    super.dispose();
  }

  FiltroHistoricoEstoque _montarFiltro() {
    final busca = _buscaController.text.trim();
    return FiltroHistoricoEstoque(
      busca: busca.isEmpty ? null : busca,
      dataInicio: _dataInicio,
      dataFim: _dataFim,
      operadorId: _usuarioSelecionado?.id,
      caixaId: _caixaSelecionado?.id,
    );
  }

  void _recarregar() {
    _bloc.add(HistoricoEstoqueIniciou(filtro: _montarFiltro()));
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final state = _bloc.state;
    if (state.step == HistoricoEstoqueStep.carregando ||
        state.step == HistoricoEstoqueStep.carregandoMais ||
        !state.temMaisPaginas) {
      return;
    }
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _bloc.add(const HistoricoEstoqueCarregarMaisSolicitado());
    }
  }

  Future<SelectData?> _selecionarDaLista({
    required String titulo,
    required List<SelectData> itens,
    required SelectData? selecionado,
  }) {
    return showModalBottomSheet<SelectData>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  titulo,
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
              ),
              for (final item in itens)
                ListTile(
                  title: Text(item.nome),
                  trailing: item.id == selecionado?.id
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () => Navigator.of(sheetContext).pop(item),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _abrirFiltroUsuario() async {
    final selecionado = await _selecionarDaLista(
      titulo: 'Usuário (operador)',
      itens: _usuarios,
      selecionado: _usuarioSelecionado,
    );
    if (selecionado == null || !mounted) return;
    setState(() => _usuarioSelecionado = selecionado);
    _recarregar();
  }

  Future<void> _abrirFiltroCaixa() async {
    final selecionado = await _selecionarDaLista(
      titulo: 'Caixa (terminal)',
      itens: _caixas,
      selecionado: _caixaSelecionado,
    );
    if (selecionado == null || !mounted) return;
    setState(() => _caixaSelecionado = selecionado);
    _recarregar();
  }

  Future<void> _abrirFiltroPeriodo() async {
    final resultado = await abrirFiltroPeriodoSheet(
      context: context,
      dataInicioAtual: _dataInicio,
      dataFimAtual: _dataFim,
      horaAjustadaManualmenteAtual: _horaAjustadaManualmente,
    );
    if (resultado == null || !mounted) return;
    setState(() {
      _dataInicio = resultado.dataInicio;
      _dataFim = resultado.dataFim;
      _horaAjustadaManualmente = resultado.horaAjustadaManualmente;
    });
    _recarregar();
  }

  String _responsavel(HistoricoEstoque item) =>
      item.funcionarioNome ??
      item.operadorNome ??
      item.caixaTerminalNome ??
      '—';

  void _irAoRomaneio(HistoricoEstoque item) {
    Navigator.pushNamed(
      context,
      '/romaneio',
      arguments: {'idRomaneio': item.romaneioId, 'permitirEdicao': false},
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HistoricoEstoqueBloc>.value(
      value: _bloc,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _buscaController,
            decoration: const InputDecoration(
              hintText: 'Buscar por referência, funcionário ou cliente',
              prefixIcon: Icon(Icons.search_outlined),
            ),
            onChanged: (_) => _debouncer.run(_recarregar),
            onSubmitted: (_) => _recarregar(),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FiltroChip(
                icon: Icons.date_range_outlined,
                label:
                    '${formatarDataHora(_dataInicio)} - ${formatarDataHora(_dataFim)}',
                onTap: _abrirFiltroPeriodo,
              ),
              FiltroChip(
                icon: Icons.person_outline,
                label: _usuarioSelecionado?.nome ?? 'Usuário',
                onTap: _abrirFiltroUsuario,
                onLimpar: _usuarioSelecionado == null
                    ? null
                    : () {
                        setState(() => _usuarioSelecionado = null);
                        _recarregar();
                      },
              ),
              FiltroChip(
                icon: Icons.point_of_sale_outlined,
                label: _caixaSelecionado?.nome ?? 'Caixa',
                onTap: _abrirFiltroCaixa,
                onLimpar: _caixaSelecionado == null
                    ? null
                    : () {
                        setState(() => _caixaSelecionado = null);
                        _recarregar();
                      },
              ),
            ],
          ),
          const SizedBox(height: SivDimensoes.gapCards),
          Expanded(
            child: BlocBuilder<HistoricoEstoqueBloc, HistoricoEstoqueState>(
              builder: (context, state) {
                if (state.step == HistoricoEstoqueStep.carregando &&
                    state.itens.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }

                if (state.step == HistoricoEstoqueStep.falha &&
                    state.itens.isEmpty) {
                  return Center(
                    child: Text(
                      state.erro ?? 'Erro ao carregar histórico.',
                      style: context.sivTextos.corpo,
                    ),
                  );
                }

                if (state.itens.isEmpty) {
                  return Center(
                    child: Text(
                      'Nenhuma movimentação encontrada para os filtros informados.',
                      style: context.sivTextos.corpo,
                    ),
                  );
                }

                final exibirLoaderFinal =
                    state.step == HistoricoEstoqueStep.carregandoMais;
                final mobile = MediaQuery.sizeOf(context).width <
                    SivDimensoes.breakpointMenuDrawer;

                if (mobile) {
                  return ListView.separated(
                    controller: _scrollController,
                    itemCount: state.itens.length + (exibirLoaderFinal ? 1 : 0),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      if (index >= state.itens.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: CircularProgressIndicator.adaptive(),
                          ),
                        );
                      }
                      return _HistoricoEstoqueCardMobile(
                        item: state.itens[index],
                        onIrAoRomaneio: () =>
                            _irAoRomaneio(state.itens[index]),
                      );
                    },
                  );
                }

                return SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SivTabela(
                        colunas: const [
                          SivTabelaColuna(titulo: 'PRODUTO', flex: 4),
                          SivTabelaColuna.numerica(titulo: 'QTD', flex: 1),
                          SivTabelaColuna(titulo: 'ROMANEIO', flex: 2),
                          SivTabelaColuna(titulo: 'RESPONSÁVEL', flex: 2),
                          SivTabelaColuna(titulo: '', flex: 2),
                        ],
                        quantidadeLinhas: state.itens.length,
                        linhaBuilder: (context, indice) {
                          final item = state.itens[indice];
                          return _linhaTabela(context, item);
                        },
                      ),
                      if (exibirLoaderFinal)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: CircularProgressIndicator.adaptive(),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _linhaTabela(BuildContext context, HistoricoEstoque item) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final corQuantidade = item.ehEntrada ? const Color(0xFF2F6A3A) : cores.vinho;

    return [
      Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text:
                  '${item.referenciaNome}${item.corNome != null ? ' · ${item.corNome}' : ''}${item.tamanhoNome != null ? ' · ${item.tamanhoNome}' : ''}\n',
              style: textos.corpo.copyWith(fontWeight: FontWeight.w600),
            ),
            TextSpan(
              text: 'Saldo após: ${item.saldoApos.toStringAsFixed(0)}',
              style: textos.apoio.copyWith(color: cores.textoApoio),
            ),
          ],
        ),
      ),
      Text(
        item.quantidade > 0
            ? '+${item.quantidade.toStringAsFixed(0)}'
            : item.quantidade.toStringAsFixed(0),
        textAlign: TextAlign.right,
        style: textos.secao.copyWith(fontSize: 16, color: corQuantidade),
      ),
      Text(
        '#RM-${item.romaneioId} · ${formatarDataHora(item.dataHora)}',
        style: textos.apoio.copyWith(color: cores.textoApoio),
      ),
      Text(
        _responsavel(item).toUpperCase(),
        style: textos.apoio.copyWith(color: cores.textoApoio),
      ),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () => _irAoRomaneio(item),
          child: const Text('Ir ao romaneio'),
        ),
      ),
    ];
  }
}

class _HistoricoEstoqueCardMobile extends StatelessWidget {
  final HistoricoEstoque item;
  final VoidCallback onIrAoRomaneio;

  const _HistoricoEstoqueCardMobile({
    required this.item,
    required this.onIrAoRomaneio,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final corQuantidade = item.ehEntrada ? const Color(0xFF2F6A3A) : cores.vinho;
    final responsavel = item.funcionarioNome ??
        item.operadorNome ??
        item.caixaTerminalNome ??
        '—';

    return SivCard(
      padding: const EdgeInsets.all(12),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.referenciaNome}${item.corNome != null ? ' · ${item.corNome}' : ''}${item.tamanhoNome != null ? ' · ${item.tamanhoNome}' : ''}',
                      style: textos.corpo.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    item.quantidade > 0
                        ? '+${item.quantidade.toStringAsFixed(0)}'
                        : item.quantidade.toStringAsFixed(0),
                    style: textos.secao.copyWith(
                      fontSize: 16,
                      color: corQuantidade,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '#RM-${item.romaneioId} · ${formatarDataHora(item.dataHora)} · ${responsavel.toUpperCase()}',
                style: textos.apoio.copyWith(color: cores.textoApoio),
              ),
              const SizedBox(height: 4),
              Text(
                'Saldo após: ${item.saldoApos.toStringAsFixed(0)}',
                style: textos.apoio.copyWith(color: cores.textoApoio),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onIrAoRomaneio,
                  child: const Text('Ir ao romaneio'),
                ),
              ),
            ],
          ),
          ...sivCantosBlueprint(cores.hairline),
        ],
      ),
    );
  }
}
