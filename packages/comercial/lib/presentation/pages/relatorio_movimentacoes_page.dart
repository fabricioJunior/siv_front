import 'package:comercial/domain/models/relatorio_movimentacoes.dart';
import 'package:comercial/domain/use_cases/get_relatorio_movimentacoes.dart';
import 'package:comercial/presentation/blocs/relatorio_movimentacoes_bloc/relatorio_movimentacoes_bloc.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

String _d2(int n) => n.toString().padLeft(2, '0');

String _fmtDia(DateTime d) => '${_d2(d.day)}/${_d2(d.month)}/${d.year}';

String _fmtDataHora(DateTime? d) =>
    d == null ? '-' : '${_d2(d.day)}/${_d2(d.month)} ${_d2(d.hour)}:${_d2(d.minute)}';

const _tipos = <(String, String)>[
  ('venda', 'Venda'),
  ('devolucao', 'Devolução'),
  ('transferencia', 'Transferência'),
  ('compra', 'Compra'),
  ('consignacao', 'Consignação'),
];

String _rotuloTipo(String tipo) {
  for (final t in _tipos) {
    if (t.$1 == tipo) return t.$2;
  }
  return tipo;
}

String _produto(MovimentacaoItem i) {
  final nome = i.produtoNome;
  final desc = i.descricao;
  if (nome == null || nome.isEmpty) return desc ?? '-';
  final ref = i.referenciaIdExterno;
  final base = ref == null || ref.isEmpty ? nome : '$nome · REF $ref';
  return desc == null || desc.isEmpty ? base : '$base $desc';
}

class RelatorioMovimentacoesPage extends StatefulWidget {
  const RelatorioMovimentacoesPage({super.key});

  @override
  State<RelatorioMovimentacoesPage> createState() =>
      _RelatorioMovimentacoesPageState();
}

class _RelatorioMovimentacoesPageState
    extends State<RelatorioMovimentacoesPage> {
  late final RelatorioMovimentacoesBloc _bloc;
  final _debouncer = Debouncer(milliseconds: 400);

  @override
  void initState() {
    super.initState();
    _bloc = RelatorioMovimentacoesBloc(sl<GetRelatorioMovimentacoes>())
      ..add(RelatorioMovimentacoesIniciou());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  Future<void> _escolherPeriodo(RelatorioMovimentacoesState s) async {
    final r = await abrirFiltroPeriodoSheet(
      context: context,
      dataInicioAtual: s.inicio,
      dataFimAtual: s.fim,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      permitirHora: false,
    );
    if (r == null || !mounted) return;
    _bloc.add(RelatorioMovimentacoesPeriodoAlterou(r.dataInicio, r.dataFim));
  }

  void _abrirDocumento(MovimentacaoItem i) {
    if (i.documentoTipo == 'romaneio' && i.documentoId != null) {
      Navigator.of(context).pushNamed(
        '/romaneio',
        arguments: {'idRomaneio': i.documentoId, 'permitirEdicao': false},
      );
    }
  }

  bool _onScroll(ScrollNotification n) {
    if (n.depth == 0 && n.metrics.extentAfter < 300) {
      _bloc.add(RelatorioMovimentacoesMaisCarregou());
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RelatorioMovimentacoesBloc>.value(
      value: _bloc,
      child: BlocBuilder<RelatorioMovimentacoesBloc,
          RelatorioMovimentacoesState>(
        builder: (context, s) {
          final primeira = s.step == RelatorioMovimentacoesStep.inicial ||
              (s.step == RelatorioMovimentacoesStep.carregando &&
                  s.items.isEmpty &&
                  s.contagemPorTipo.isEmpty);
          final falha = s.step == RelatorioMovimentacoesStep.falha;
          return Scaffold(
            body: SafeArea(
              child: NotificationListener<ScrollNotification>(
                onNotification: _onScroll,
                child: RelatorioScaffold(
                  titulo: 'Movimentações do sistema',
                  filtros: [
                    RelatorioFiltroChip(
                      rotulo: 'Período',
                      valor: '${_fmtDia(s.inicio)} - ${_fmtDia(s.fim)}',
                      onTap: () => _escolherPeriodo(s),
                    ),
                  ],
                  carregando: primeira,
                  erro: falha ? (s.erro ?? 'Falha ao carregar') : null,
                  onTentarDeNovo: () =>
                      _bloc.add(RelatorioMovimentacoesRecarregou()),
                  corpo: _Corpo(
                    state: s,
                    onTipo: (t) =>
                        _bloc.add(RelatorioMovimentacoesTipoAlternou(t)),
                    onBusca: (v) => _debouncer.run(
                      () => _bloc.add(RelatorioMovimentacoesBuscou(v)),
                    ),
                    onTap: _abrirDocumento,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Corpo extends StatelessWidget {
  final RelatorioMovimentacoesState state;
  final ValueChanged<String?> onTipo;
  final ValueChanged<String> onBusca;
  final ValueChanged<MovimentacaoItem> onTap;

  const _Corpo({
    required this.state,
    required this.onTipo,
    required this.onBusca,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final c = state.contagemPorTipo;
    final total = c.values.fold<int>(0, (a, b) => a + b);
    final carregando = state.step == RelatorioMovimentacoesStep.carregando;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            RelatorioFiltroChip.toggle(
              rotulo: 'Todas ($total)',
              marcado: state.tipos.isEmpty,
              onChanged: (_) => onTipo(null),
            ),
            for (final t in _tipos)
              if (c.containsKey(t.$1))
                RelatorioFiltroChip.toggle(
                  rotulo: '${t.$2} (${c[t.$1] ?? 0})',
                  marcado: state.tipos.contains(t.$1),
                  onChanged: (_) => onTipo(t.$1),
                ),
            SizedBox(
              width: 240,
              child: TextField(
                onChanged: onBusca,
                style: textos.apoio,
                decoration: const InputDecoration(
                  isDense: true,
                  hintText: 'Buscar produto ou referência',
                  prefixIcon: Icon(Icons.search, size: 18),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (carregando) const LinearProgressIndicator(minHeight: 2),
        if (state.items.isEmpty && !carregando)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Text(
              'Nenhum resultado para o filtro selecionado.',
              textAlign: TextAlign.center,
              style: textos.corpo.copyWith(color: cores.textoApoio),
            ),
          )
        else
          RelatorioTabela<MovimentacaoItem>(
            colunas: const [
              RelatorioColuna(id: 'data', titulo: 'Data/Hora', flex: 2, ordenavel: false),
              RelatorioColuna(id: 'tipo', titulo: 'Tipo', flex: 2, ordenavel: false),
              RelatorioColuna(
                  id: 'produto', titulo: 'Produto / Referência', flex: 6, ordenavel: false),
              RelatorioColuna(
                  id: 'qtd', titulo: 'Qtd', numerica: true, ordenavel: false),
              RelatorioColuna(
                  id: 'resp', titulo: 'Responsável', flex: 3, ordenavel: false),
            ],
            itens: state.items,
            onTap: onTap,
            celulas: (ctx, i) => [
              Text(_fmtDataHora(i.dataHora), style: textos.corpo),
              _TipoTag(tipo: i.tipo),
              Text(_produto(i), style: textos.corpo),
              Text('${i.quantidade}',
                  style: textos.corpo.copyWith(fontWeight: FontWeight.w700)),
              Text(i.responsavelNome ?? '-',
                  style: textos.corpo.copyWith(color: cores.textoApoio)),
            ],
            itemMobile: (ctx, i) => RelatorioItemMobile(
              titulo: '${_rotuloTipo(i.tipo)} ${_produto(i)}',
              apoio: [
                _fmtDataHora(i.dataHora),
                if (i.responsavelNome != null) i.responsavelNome!,
              ],
              valor: '${i.quantidade}',
            ),
          ),
        if (state.carregandoMais)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
      ],
    );
  }
}

class _TipoTag extends StatelessWidget {
  final String tipo;
  const _TipoTag({required this.tipo});

  @override
  Widget build(BuildContext context) {
    final c = context.sivColors;
    final (Color fg, Color borda, Color? fundo) = switch (tipo) {
      'venda' => (c.acoEscuro, c.aco, c.selecaoFundo),
      'devolucao' => (c.vinho, c.vinho, null),
      'compra' => (c.verde, c.verde, null),
      'consignacao' => (c.atencao, c.atencaoBorda, c.atencaoFundo),
      _ => (c.textoApoio, c.hairline, null),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: fundo,
        border: Border.all(color: borda),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _rotuloTipo(tipo),
        style: context.sivTextos.apoio.copyWith(color: fg),
      ),
    );
  }
}
