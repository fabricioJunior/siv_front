import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:estoque/domain/models/relatorio_produtos_defasados.dart';
import 'package:estoque/presentation/blocs/relatorio_produtos_defasados_bloc/relatorio_produtos_defasados_bloc.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';

String _fmtMoeda(double v) {
  final s = v.toStringAsFixed(2);
  final p = s.split('.');
  final inteiro = p[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]}.',
  );
  return 'R\$ $inteiro,${p[1]}';
}

String _fmtData(String? iso) {
  if (iso == null || iso.isEmpty) return '-';
  final p = iso.split('T').first.split('-');
  return p.length == 3 ? '${p[2]}/${p[1]}/${p[0]}' : iso;
}

class RelatorioProdutosDefasadosPage extends StatefulWidget {
  const RelatorioProdutosDefasadosPage({super.key});

  @override
  State<RelatorioProdutosDefasadosPage> createState() =>
      _RelatorioProdutosDefasadosPageState();
}

class _RelatorioProdutosDefasadosPageState
    extends State<RelatorioProdutosDefasadosPage> {
  late final RelatorioProdutosDefasadosBloc _bloc;
  late final TextEditingController _diasController;
  late final TextEditingController _buscaController;
  String _tipoMovimentacao = 'ambas';
  String _visualizacao = 'produto';
  List<Cor> _cores = [];
  List<Tamanho> _tamanhos = [];
  ModoAgrupamentoReferencia _modoAgrupamento =
      ModoAgrupamentoReferencia.todos;
  String _ordenarPor = 'dias';
  bool _ascendente = false;

  @override
  void initState() {
    super.initState();
    _diasController = TextEditingController(text: '90');
    _buscaController = TextEditingController();
    _bloc = sl<RelatorioProdutosDefasadosBloc>()
      ..add(RelatorioProdutosDefasadosCarregar());
  }

  @override
  void dispose() {
    _diasController.dispose();
    _buscaController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _aplicar({int page = 1}) {
    final dias = int.tryParse(_diasController.text) ?? 90;
    setState(() {});
    _bloc.add(RelatorioProdutosDefasadosCarregar(
      dias: dias.clamp(1, 3650),
      tipoMovimentacao: _tipoMovimentacao,
      visualizacao: _visualizacao,
      corIds: _cores.isEmpty
          ? null
          : _cores.map((c) => c.id!).toList(),
      tamanhoIds: _tamanhos.isEmpty
          ? null
          : _tamanhos.map((t) => t.id!).toList(),
      modoAgrupamentoReferencia: _modoAgrupamento,
      busca: _buscaController.text.trim().isEmpty
          ? null
          : _buscaController.text.trim(),
      page: page,
    ));
  }

  int _dias() => (int.tryParse(_diasController.text) ?? 90).clamp(1, 3650);

  String get _rotuloTipo => switch (_tipoMovimentacao) {
        'entrada' => 'Somente entrada',
        'saida' => 'Somente saída',
        _ => 'Entrada e saída',
      };

  Object? _chave(RelatorioProdutoDefasadoItem i, String id) => switch (id) {
        'produto' => i.referenciaNome.toLowerCase(),
        'grade' => '${i.corNome} ${i.tamanhoNome}'.toLowerCase(),
        'saldo' => i.saldo,
        'valor' => i.valorTotal,
        _ => i.diasSemMovimentacao ?? -1,
      };

  List<RelatorioProdutoDefasadoItem> _ordenar(
      List<RelatorioProdutoDefasadoItem> itens) {
    final l = [...itens];
    l.sort((a, b) {
      final c = Comparable.compare(
          _chave(a, _ordenarPor) as Comparable, _chave(b, _ordenarPor) as Comparable);
      return _ascendente ? c : -c;
    });
    return l;
  }

  void _ordenarColuna(String id) => setState(() {
        if (_ordenarPor == id) {
          _ascendente = !_ascendente;
        } else {
          _ordenarPor = id;
          _ascendente = id == 'produto' || id == 'grade';
        }
      });

  Future<void> _abrirFiltros() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          void s(VoidCallback f) {
            setState(f);
            setS(() {});
          }

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
                16, 0, 16, 16 + MediaQuery.viewInsetsOf(ctx).bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _diasController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Dias sem movimentação',
                    isDense: true,
                    suffixText: 'dias',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _buscaController,
                  decoration: const InputDecoration(
                    labelText: 'Buscar',
                    isDense: true,
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Tipo de movimentação',
                    style: Theme.of(ctx).textTheme.bodySmall),
                const SizedBox(height: 6),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment<String>(
                      value: 'entrada',
                      icon: Icon(Icons.arrow_downward),
                      label: Text('Entrada'),
                    ),
                    ButtonSegment<String>(
                      value: 'saida',
                      icon: Icon(Icons.arrow_upward),
                      label: Text('Saída'),
                    ),
                    ButtonSegment<String>(
                      value: 'ambas',
                      icon: Icon(Icons.swap_vert),
                      label: Text('Ambas'),
                    ),
                  ],
                  selected: {_tipoMovimentacao},
                  onSelectionChanged: (v) =>
                      s(() => _tipoMovimentacao = v.first),
                ),
                const SizedBox(height: 12),
                CorSeletor(
                  modo: CorSeletorModo.multipla,
                  coresSelecionadasIniciais: _cores,
                  onCorChanged: (cores) => s(() => _cores = cores),
                ),
                const SizedBox(height: 12),
                TamanhoSeletor(
                  modo: TamanhoSeletorModo.multipla,
                  tamanhosSelecionadosIniciais: _tamanhos,
                  onTamanhosChanged: (t) => s(() => _tamanhos = t),
                ),
                const SizedBox(height: 12),
                Text('Visualização',
                    style: Theme.of(ctx).textTheme.bodySmall),
                const SizedBox(height: 6),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment<String>(
                      value: 'produto',
                      icon: Icon(Icons.inventory_2_outlined),
                      label: Text('Por produto'),
                    ),
                    ButtonSegment<String>(
                      value: 'referencia',
                      icon: Icon(Icons.category_outlined),
                      label: Text('Por referência'),
                    ),
                  ],
                  selected: {_visualizacao},
                  onSelectionChanged: (v) => s(() => _visualizacao = v.first),
                ),
                if (_visualizacao == 'referencia') ...[
                  const SizedBox(height: 12),
                  Text('Quando a referência conta como defasada',
                      style: Theme.of(ctx).textTheme.bodySmall),
                  const SizedBox(height: 6),
                  SegmentedButton<ModoAgrupamentoReferencia>(
                    segments: const [
                      ButtonSegment<ModoAgrupamentoReferencia>(
                        value: ModoAgrupamentoReferencia.todos,
                        label: Text('Todos os produtos defasados'),
                      ),
                      ButtonSegment<ModoAgrupamentoReferencia>(
                        value: ModoAgrupamentoReferencia.qualquer,
                        label: Text('Pelo menos um produto defasado'),
                      ),
                    ],
                    selected: {_modoAgrupamento},
                    onSelectionChanged: (v) =>
                        s(() => _modoAgrupamento = v.first),
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _aplicar();
                    },
                    icon: const Icon(Icons.search),
                    label: const Text('Consultar'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RelatorioProdutosDefasadosBloc>.value(
      value: _bloc,
      child: BlocBuilder<RelatorioProdutosDefasadosBloc,
          RelatorioProdutosDefasadosState>(
        builder: (context, state) {
          final dados = state.dados;
          final ok =
              state.step == RelatorioProdutosDefasadosStep.sucesso &&
                  dados != null;
          return Scaffold(
            body: SafeArea(
              child: RelatorioScaffold(
                titulo: 'Produtos Defasados',
                filtros: [
                  RelatorioFiltroChip(
                    rotulo: 'Sem giro há ${_dias()}+ dias',
                    onTap: _abrirFiltros,
                  ),
                  RelatorioFiltroChip(
                    rotulo: _rotuloTipo,
                    onTap: _abrirFiltros,
                  ),
                  RelatorioFiltroChip(
                    rotulo: _visualizacao == 'produto'
                        ? 'Cor / Tamanho'
                        : 'Por referência',
                    onTap: _abrirFiltros,
                  ),
                ],
                kpis: ok
                    ? [
                        RelatorioKpiCard(
                          rotulo: 'Itens defasados',
                          valor: '${dados.resumo.quantidadeDefasados}',
                          tom: RelatorioKpiTom.atencao,
                        ),
                        RelatorioKpiCard(
                          rotulo: 'Valor em estoque',
                          valor: _fmtMoeda(dados.resumo.valorTotalDefasado),
                        ),
                      ]
                    : const [],
                carregando:
                    state.step == RelatorioProdutosDefasadosStep.carregando ||
                        state.step == RelatorioProdutosDefasadosStep.inicial,
                erro: state.step == RelatorioProdutosDefasadosStep.falha
                    ? (state.erro ?? 'Falha ao carregar')
                    : null,
                onTentarDeNovo: _aplicar,
                vazio: ok && dados.items.isEmpty,
                corpo: ok ? _corpo(context, state, dados) : const SizedBox(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _corpo(BuildContext context, RelatorioProdutosDefasadosState state,
      RelatorioProdutosDefasados dados) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    return Column(
      children: [
        RelatorioTabela<RelatorioProdutoDefasadoItem>(
          colunas: const [
            RelatorioColuna(id: 'produto', titulo: 'Produto', flex: 4),
            RelatorioColuna(id: 'grade', titulo: 'Grade', flex: 3),
            RelatorioColuna(id: 'saldo', titulo: 'Saldo'),
            RelatorioColuna(id: 'valor', titulo: 'Valor', numerica: true, flex: 2),
            RelatorioColuna(id: 'dias', titulo: 'Sem giro há', flex: 2),
          ],
          itens: _ordenar(dados.items),
          ordenarPor: _ordenarPor,
          ascendente: _ascendente,
          onOrdenar: _ordenarColuna,
          celulas: (_, i) => [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(i.referenciaNome,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textos.corpo.copyWith(fontWeight: FontWeight.w600)),
                Text(
                  'REF ${i.referenciaIdExterno}'
                  '${i.marcaNome == null ? '' : ' · ${i.marcaNome}'}',
                  style: textos.apoio.copyWith(color: cores.textoApoio),
                ),
              ],
            ),
            Text('${i.corNome} · ${i.tamanhoNome}', style: textos.corpo),
            SizedBox(
              width: double.infinity,
              child: Text(
                '${i.saldo}',
                textAlign: TextAlign.center,
                style: textos.corpo
                    .copyWith(fontFamily: sivFonteCondensed, fontSize: 16),
              ),
            ),
            Text(_fmtMoeda(i.valorTotal), style: textos.corpo),
            Text(
              i.diasSemMovimentacao == null
                  ? '-'
                  : '${i.diasSemMovimentacao} dias',
              style: textos.corpo.copyWith(
                  color: cores.atencao, fontWeight: FontWeight.w700),
            ),
          ],
          itemMobile: (_, i) => RelatorioItemMobile(
            titulo: '${i.referenciaNome} · ${i.corNome} · ${i.tamanhoNome}',
            apoio: [
              'REF ${i.referenciaIdExterno}'
                  '${i.marcaNome == null ? '' : ' · ${i.marcaNome}'}',
              'Saldo ${i.saldo}',
              if (i.diasSemMovimentacao != null)
                '${i.diasSemMovimentacao} dias sem giro',
              'Últ. entrada ${_fmtData(i.ultimaEntrada)}',
              'Últ. saída ${_fmtData(i.ultimaSaida)}',
            ],
            valor: _fmtMoeda(i.valorTotal),
          ),
        ),
        if (state.totalPages > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.chevron_left),
                label: const Text('Anterior'),
                onPressed:
                    state.page > 1 ? () => _aplicar(page: state.page - 1) : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('${state.page}/${state.totalPages}',
                    style: textos.corpo.copyWith(fontWeight: FontWeight.w600)),
              ),
              TextButton.icon(
                icon: const Icon(Icons.chevron_right),
                label: const Text('Próxima'),
                onPressed: state.page < state.totalPages
                    ? () => _aplicar(page: state.page + 1)
                    : null,
              ),
            ],
          ),
      ],
    );
  }
}
