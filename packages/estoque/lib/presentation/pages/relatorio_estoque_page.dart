import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:estoque/domain/models/relatorio_posicao_estoque.dart';
import 'package:estoque/domain/usecases/get_relatorio_posicao_estoque.dart';
import 'package:estoque/presentation/blocs/relatorio_posicao_estoque_bloc/relatorio_posicao_estoque_bloc.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';

String _fmtMoeda(double v) {
  final p = v.toStringAsFixed(2).split('.');
  final inteiro = p[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]}.',
  );
  return 'R\$ $inteiro,${p[1]}';
}

String _fmtPct(double v) => '${v.toStringAsFixed(1).replaceFirst('.', ',')}%';

String _fmtData(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

class RelatorioEstoquePage extends StatefulWidget {
  const RelatorioEstoquePage({super.key});

  @override
  State<RelatorioEstoquePage> createState() => _RelatorioEstoquePageState();
}

class _RelatorioEstoquePageState extends State<RelatorioEstoquePage> {
  late final RelatorioPosicaoEstoqueBloc _bloc;
  List<Categoria> _categorias = [];
  List<Cor> _cores = [];
  List<Tamanho> _tamanhos = [];

  @override
  void initState() {
    super.initState();
    _bloc = RelatorioPosicaoEstoqueBloc(sl<GetRelatorioPosicaoEstoque>())
      ..add(const PosicaoEstoqueIniciou());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  String _rotuloLista(List<Object> l, String Function(int) nome) =>
      l.isEmpty ? 'Todas' : (l.length == 1 ? nome(0) : '${l.length} selecionadas');

  Future<void> _abrirFiltros() async {
    var situacao = _bloc.state.situacao;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
              16, 0, 16, 16 + MediaQuery.viewInsetsOf(ctx).bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CategoriaSeletor(
                modo: CategoriaSeletorModo.multipla,
                idCategoriasSelecionadasIniciais:
                    _categorias.map((c) => c.id!).toList(),
                onCategoriaChanged: (l) => _categorias = l,
              ),
              const SizedBox(height: 12),
              Text('Situação', style: Theme.of(ctx).textTheme.bodySmall),
              const SizedBox(height: 6),
              SegmentedButton<String?>(
                emptySelectionAllowed: true,
                segments: const [
                  ButtonSegment(value: 'ruptura', label: Text('Ruptura')),
                  ButtonSegment(value: 'normal', label: Text('Normal')),
                ],
                selected: {?situacao},
                onSelectionChanged: (v) =>
                    setS(() => situacao = v.isEmpty ? null : v.first),
              ),
              const SizedBox(height: 12),
              CorSeletor(
                modo: CorSeletorModo.multipla,
                coresSelecionadasIniciais: _cores,
                onCorChanged: (l) => _cores = l,
              ),
              const SizedBox(height: 12),
              TamanhoSeletor(
                modo: TamanhoSeletorModo.multipla,
                tamanhosSelecionadosIniciais: _tamanhos,
                onTamanhosChanged: (l) => _tamanhos = l,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _bloc.add(PosicaoEstoqueFiltrosAlterados(
                      categoriaIds: _categorias.map((c) => c.id!).toList(),
                      corIds: _cores.map((c) => c.id!).toList(),
                      tamanhoIds: _tamanhos.map((t) => t.id!).toList(),
                      situacao: situacao,
                    ));
                    setState(() {});
                  },
                  icon: const Icon(Icons.search),
                  label: const Text('Consultar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RelatorioPosicaoEstoqueBloc>.value(
      value: _bloc,
      child: BlocBuilder<RelatorioPosicaoEstoqueBloc,
          RelatorioPosicaoEstoqueState>(
        builder: (context, state) {
          final dados = state.dados;
          final ok = state.step == PosicaoEstoqueStep.sucesso && dados != null;
          final cores = context.sivColors;
          final textos = context.sivTextos;
          final situacao = switch (state.situacao) {
            'ruptura' => 'Ruptura',
            'normal' => 'Normal',
            _ => 'Todas',
          };
          return Scaffold(
            body: SafeArea(
              child: RelatorioScaffold(
                titulo: 'Estoque',
                acoes: [
                  if (dados?.dataReferencia != null)
                    Text(
                      'Posição em ${_fmtData(dados!.dataReferencia!)}',
                      style: textos.apoio.copyWith(color: cores.textoApoio),
                    ),
                ],
                filtros: [
                  RelatorioFiltroChip(
                    rotulo: 'Categoria',
                    valor: _rotuloLista(
                        _categorias, (i) => _categorias[i].nome),
                    onTap: _abrirFiltros,
                  ),
                  RelatorioFiltroChip(
                    rotulo: 'Situação',
                    valor: situacao,
                    onTap: _abrirFiltros,
                  ),
                  RelatorioFiltroChip(
                    rotulo: 'Cor',
                    valor: _rotuloLista(_cores, (i) => _cores[i].nome),
                    onTap: _abrirFiltros,
                  ),
                  RelatorioFiltroChip(
                    rotulo: 'Tamanho',
                    valor: _rotuloLista(_tamanhos, (i) => _tamanhos[i].nome),
                    onTap: _abrirFiltros,
                  ),
                  RelatorioFiltroChip.toggle(
                    rotulo: 'Em ruptura ${dados?.resumo.emRuptura ?? 0}',
                    marcado: state.ruptura,
                    onChanged: (_) =>
                        _bloc.add(const PosicaoEstoqueRupturaAlternada()),
                  ),
                ],
                kpis: ok
                    ? [
                        RelatorioKpiCard(
                          rotulo: 'VALOR EM ESTOQUE',
                          valor: _fmtMoeda(dados.resumo.valorEstoque),
                          destaque: true,
                        ),
                        RelatorioKpiCard(
                          rotulo: 'PEÇAS EM ESTOQUE',
                          valor: '${dados.resumo.pecas}',
                        ),
                        RelatorioKpiCard(
                          rotulo: 'SKUS ATIVOS',
                          valor: '${dados.resumo.skusAtivos}',
                        ),
                        RelatorioKpiCard(
                          rotulo: 'EM RUPTURA',
                          valor: '${dados.resumo.emRuptura}',
                          valorVinho: true,
                        ),
                      ]
                    : const [],
                carregando: state.step == PosicaoEstoqueStep.carregando ||
                    state.step == PosicaoEstoqueStep.inicial,
                erro: state.step == PosicaoEstoqueStep.falha
                    ? (state.erro ?? 'Falha ao carregar')
                    : null,
                onTentarDeNovo: () => _bloc.add(const PosicaoEstoqueIniciou()),
                vazio: ok && dados.items.isEmpty,
                corpo: ok ? _corpo(context, state, dados) : const SizedBox(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _corpo(BuildContext context, RelatorioPosicaoEstoqueState state,
      RelatorioPosicaoEstoque dados) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final ruptura = state.ruptura;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (dados.baseValor == 'venda')
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Valor calculado pelo preço de venda.',
              style: textos.apoio.copyWith(color: cores.textoApoio),
            ),
          ),
        RelatorioTabela<PosicaoEstoqueCategoria>(
          colunas: const [
            RelatorioColuna(id: 'categoria', titulo: 'CATEGORIA', flex: 4),
            RelatorioColuna(id: 'pecas', titulo: 'PEÇAS', numerica: true),
            RelatorioColuna(
                id: 'valor', titulo: 'VALOR', numerica: true, flex: 2),
            RelatorioColuna(
                id: 'percentual', titulo: '% DO TOTAL', numerica: true),
          ],
          itens: dados.items,
          ordenarPor: state.ordenarPor,
          ascendente: state.ordem == 'asc',
          onOrdenar: (id) => _bloc.add(PosicaoEstoqueOrdenou(id)),
          celulas: (_, i) => [
            Text(i.categoriaNome,
                style: textos.corpo.copyWith(fontWeight: FontWeight.w600)),
            Text(ruptura ? '${i.emRuptura}' : '${i.pecas}',
                style: textos.corpo),
            Text(ruptura ? '-' : _fmtMoeda(i.valor), style: textos.corpo),
            Text(ruptura ? '-' : _fmtPct(i.percentual), style: textos.corpo),
          ],
          itemMobile: (_, i) => RelatorioItemMobile(
            titulo: i.categoriaNome,
            apoio: [
              ruptura
                  ? '${i.emRuptura} em ruptura'
                  : '${i.pecas} peças · ${_fmtPct(i.percentual)}',
            ],
            valor: ruptura ? '${i.emRuptura}' : _fmtMoeda(i.valor),
          ),
        ),
      ],
    );
  }
}
