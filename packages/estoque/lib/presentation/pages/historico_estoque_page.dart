import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/seletores.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HistoricoEstoqueBloc>.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(title: const Text('Histórico de Estoque')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                SearchBar(
                  controller: _buscaController,
                  hintText: 'Buscar por referência, funcionário ou cliente',
                  onChanged: (_) => _debouncer.run(_recarregar),
                  onSubmitted: (_) => _recarregar(),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
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
                ),
                const SizedBox(height: 8),
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
                          ),
                        );
                      }

                      if (state.itens.isEmpty) {
                        return const Center(
                          child: Text(
                            'Nenhuma movimentação encontrada para os filtros informados.',
                          ),
                        );
                      }

                      final exibirLoaderFinal =
                          state.step == HistoricoEstoqueStep.carregandoMais;

                      return ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(top: 8),
                        itemCount:
                            state.itens.length + (exibirLoaderFinal ? 1 : 0),
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
                          return _HistoricoEstoqueCard(
                            item: state.itens[index],
                          );
                        },
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
  }
}

class _HistoricoEstoqueCard extends StatelessWidget {
  final HistoricoEstoque item;

  const _HistoricoEstoqueCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final corQuantidade = item.ehEntrada ? Colors.green : Colors.red;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${item.referenciaNome}${item.corNome != null ? ' • ${item.corNome}' : ''}${item.tamanhoNome != null ? ' • ${item.tamanhoNome}' : ''}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  item.quantidade > 0
                      ? '+${item.quantidade.toStringAsFixed(0)}'
                      : item.quantidade.toStringAsFixed(0),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: corQuantidade,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Romaneio #${item.romaneioId}  •  ${formatarDataHora(item.dataHora)}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colorScheme.outline),
            ),
            const SizedBox(height: 4),
            Text(
              'Saldo após: ${item.saldoApos.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (item.pessoaNome != null) ...[
              const SizedBox(height: 4),
              Text(
                'Cliente: ${item.pessoaNome!.toUpperCase()}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (item.funcionarioNome != null || item.operadorNome != null) ...[
              const SizedBox(height: 4),
              Text(
                [
                  if (item.funcionarioNome != null)
                    'Funcionário: ${item.funcionarioNome!.toUpperCase()}',
                  if (item.operadorNome != null)
                    'Usuário: ${item.operadorNome!.toUpperCase()}',
                ].join('  •  '),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/romaneio',
                    arguments: {
                      'idRomaneio': item.romaneioId,
                      'permitirEdicao': false,
                    },
                  );
                },
                icon: const Icon(Icons.receipt_long_outlined, size: 16),
                label: const Text('Ir ao romaneio'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
