import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/seletores.dart';
import 'package:core/tema.dart';
import 'package:estoque/domain/models/parametros_giro.dart';
import 'package:estoque/domain/models/relatorio_giro_estoque.dart';
import 'package:estoque/presentation/blocs/relatorio_giro_estoque_bloc/relatorio_giro_estoque_bloc.dart';
import 'package:estoque/presentation/pages/giro_estoque/giro_formatacao.dart';
import 'package:estoque/presentation/pages/giro_estoque/giro_mobile.dart';
import 'package:estoque/presentation/pages/giro_estoque/giro_painel.dart';
import 'package:estoque/presentation/pages/giro_estoque/giro_tabela.dart';
import 'package:estoque/presentation/pages/giro_estoque/giro_widgets.dart';
import 'package:flutter/material.dart';

const _breakpointDesktop = 720.0;

/// Relatório "Giro de Estoque" (RELFC013). Seletores chegam por construtor
/// (montados em `routes.dart`) para o pacote não depender de quem os implementa.
class RelatorioGiroEstoquePage extends StatefulWidget {
  final SeletorWidget seletorCategorias;
  final SeletorWidget seletorFornecedores;
  final SeletorWidget seletorMarcas;
  final SeletorWidget seletorTamanhos;
  final SeletorWidget seletorCores;

  const RelatorioGiroEstoquePage({
    super.key,
    required this.seletorCategorias,
    required this.seletorFornecedores,
    required this.seletorMarcas,
    required this.seletorTamanhos,
    required this.seletorCores,
  });

  @override
  State<RelatorioGiroEstoquePage> createState() => _RelatorioGiroEstoquePageState();
}

class _RelatorioGiroEstoquePageState extends State<RelatorioGiroEstoquePage> {
  late final RelatorioGiroEstoqueBloc _bloc;
  final _buscaController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 400);
  final Map<String, List<SelectData>> _sel = {};

  late final Map<String, SeletorWidget> _seletores = {
    'Categoria': widget.seletorCategorias,
    'Fornecedor': widget.seletorFornecedores,
    'Marca': widget.seletorMarcas,
    'Tamanho': widget.seletorTamanhos,
    'Cor': widget.seletorCores,
  };

  @override
  void initState() {
    super.initState();
    _bloc = sl<RelatorioGiroEstoqueBloc>()..add(GiroEstoqueIniciou());
  }

  @override
  void dispose() {
    _debouncer.cancel();
    _buscaController.dispose();
    _bloc.close();
    super.dispose();
  }

  FiltroGiroEstoque _montarFiltro({
    String? busca,
    double? precoMin,
    double? precoMax,
  }) {
    final s = _sel;
    List<int> ids(String k) => (s[k] ?? const []).map((e) => e.id).toList();
    final atual = _bloc.state.filtro;
    return atual.copyWith(
      categoriaIds: ids('Categoria'),
      fornecedorIds: ids('Fornecedor'),
      marcaIds: ids('Marca'),
      tamanhoIds: ids('Tamanho'),
      corIds: ids('Cor'),
      precoMin: precoMin,
      precoMax: precoMax,
      limparPreco: precoMin == null && precoMax == null,
      busca: busca,
      limparBusca: busca == null || busca.isEmpty,
      rotulos: {
        for (final e in s.entries)
          if (e.value.isNotEmpty) e.key: e.value.map((x) => x.nome).join(', '),
      },
    );
  }

  void _emitirFiltro({double? precoMin, double? precoMax, bool preco = false}) {
    final f = _bloc.state.filtro;
    _bloc.add(GiroFiltroAlterado(_montarFiltro(
      busca: _buscaController.text.trim(),
      precoMin: preco ? precoMin : f.precoMin,
      precoMax: preco ? precoMax : f.precoMax,
    )));
  }

  void _limparFiltros() {
    _sel.clear();
    _buscaController.clear();
    final f = _bloc.state.filtro;
    _bloc.add(GiroFiltroAlterado(FiltroGiroEstoque(
      periodo: f.periodo,
      dataInicio: f.dataInicio,
      dataFim: f.dataFim,
      visualizacao: f.visualizacao,
    )));
  }

  Future<void> _escolherPeriodo(PeriodoGiro p) async {
    if (p != PeriodoGiro.personalizado) {
      _bloc.add(GiroPeriodoAlterado(p));
      return;
    }
    final (ini, fim) = _bloc.state.filtro.intervalo();
    final r = await abrirFiltroPeriodoSheet(
      context: context,
      dataInicioAtual: ini,
      dataFimAtual: fim,
      permitirHora: false,
    );
    if (r != null) {
      _bloc.add(GiroPeriodoAlterado(p, dataInicio: r.dataInicio, dataFim: r.dataFim));
    }
  }

  Future<void> _escolherSeletor(String chave) async {
    var temp = _sel[chave] ?? const <SelectData>[];
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(chave),
        content: SizedBox(
          width: 420,
          child: _seletores[chave]!(SeletorData(
            itemsSelecionadosInicial: temp,
            onChanged: (l) => temp = l,
          )),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Aplicar')),
        ],
      ),
    );
    if (ok == true) {
      _sel[chave] = temp;
      _emitirFiltro();
    }
  }

  Future<void> _escolherPreco() async {
    final f = _bloc.state.filtro;
    final min = TextEditingController(text: f.precoMin?.toString() ?? '');
    final max = TextEditingController(text: f.precoMax?.toString() ?? '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Preço de venda'),
        content: _CamposPreco(min: min, max: max),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Aplicar')),
        ],
      ),
    );
    if (ok == true) {
      _emitirFiltro(
        preco: true,
        precoMin: _numero(min.text),
        precoMax: _numero(max.text),
      );
    }
    min.dispose();
    max.dispose();
  }

  Future<void> _filtrosMobile() async {
    final sel = {for (final e in _sel.entries) e.key: e.value};
    final f = _bloc.state.filtro;
    final min = TextEditingController(text: f.precoMin?.toString() ?? '');
    final max = TextEditingController(text: f.precoMax?.toString() ?? '');
    final aplicar = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            for (final e in _seletores.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: e.value(SeletorData(
                  itemsSelecionadosInicial: sel[e.key],
                  onChanged: (l) => sel[e.key] = l,
                )),
              ),
            _CamposPreco(min: min, max: max),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    sel.clear();
                    min.clear();
                    max.clear();
                    Navigator.pop(ctx, true);
                  },
                  child: const Text('Limpar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Aplicar'),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
    if (aplicar == true) {
      final pMin = _numero(min.text);
      final pMax = _numero(max.text);
      _sel
        ..clear()
        ..addAll(sel);
      _emitirFiltro(preco: true, precoMin: pMin, precoMax: pMax);
    }
    min.dispose();
    max.dispose();
  }

  static double? _numero(String t) =>
      double.tryParse(t.trim().replaceAll(',', '.'));

  @override
  Widget build(BuildContext context) => BlocProvider<RelatorioGiroEstoqueBloc>.value(
        value: _bloc,
        child: BlocListener<RelatorioGiroEstoqueBloc, RelatorioGiroEstoqueState>(
          listenWhen: (a, b) => b.erroExportacao != null && a.erroExportacao != b.erroExportacao,
          listener: (context, s) => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(s.erroExportacao!))),
          child: LayoutBuilder(
            builder: (context, c) {
              final desktop = c.maxWidth >= _breakpointDesktop;
              return BlocBuilder<RelatorioGiroEstoqueBloc, RelatorioGiroEstoqueState>(
                builder: (context, s) => Scaffold(
                  backgroundColor: giroPapel,
                  appBar: desktop ? _appBarDesktop(s) : _appBarMobile(s),
                  body: desktop ? _desktop(s) : _mobile(s),
                ),
              );
            },
          ),
        ),
      );

  Widget _botaoExportar(RelatorioGiroEstoqueState s, Widget child) =>
      PopupMenuButton<FormatoExportacaoGiro>(
        enabled: !s.exportando && s.listaStep == GiroSecaoStep.sucesso,
        tooltip: 'Exportar aba ativa',
        onSelected: (f) => _bloc.add(GiroExportarSolicitado(f)),
        itemBuilder: (_) => const [
          PopupMenuItem(value: FormatoExportacaoGiro.csv, child: Text('CSV')),
          PopupMenuItem(value: FormatoExportacaoGiro.pdf, child: Text('PDF')),
        ],
        child: child,
      );

  PreferredSizeWidget _appBarDesktop(RelatorioGiroEstoqueState s) => AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 72,
        titleSpacing: 34,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
            Text('Relatórios /', style: giroCorpo(context, 13, cor: giroTinta.withValues(alpha: .45))),
            const SizedBox(width: 10),
            Text('Giro de estoque', style: context.sivTextos.secao.copyWith(fontSize: 21)),
          ]),
          Text(periodoTexto(s.filtro), style: giroCorpo(context, 11.5, cor: giroApoio)),
        ]),
        actions: [
          _SeletorPeriodo(atual: s.filtro.periodo, onChanged: _escolherPeriodo),
          const SizedBox(width: 10),
          _botaoExportar(
            s,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(border: Border.all(color: giroTinta.withValues(alpha: .18))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                s.exportando
                    ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.file_download_outlined, size: 16),
                const SizedBox(width: 7),
                Text('Exportar', style: giroCorpo(context, 13)),
              ]),
            ),
          ),
          const SizedBox(width: 34),
        ],
      );

  PreferredSizeWidget _appBarMobile(RelatorioGiroEstoqueState s) => AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text('Giro de estoque', style: context.sivTextos.secao.copyWith(fontSize: 19)),
        actions: [
          _botaoExportar(
            s,
            Padding(
              padding: const EdgeInsets.all(12),
              child: s.exportando
                  ? const SizedBox(width: 19, height: 19, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.file_download_outlined, size: 22),
            ),
          ),
        ],
      );

  // ---------------------------------------------------------------- desktop

  Widget _desktop(RelatorioGiroEstoqueState s) {
    final r = s.resumo;
    return ListView(
      padding: const EdgeInsets.fromLTRB(30, 24, 30, 32),
      children: [
        if (r != null) ...[
          GiroPainelClassificacao(
            resumo: r,
            selecionadas: s.filtro.classificacoes,
            onFaixa: (c) => _bloc.add(GiroClassificacaoSelecionada(c)),
            onCriterios: () => _bloc.add(GiroCriteriosAlternados()),
          ),
          if (s.criteriosAbertos) ...[
            const SizedBox(height: 20),
            GiroCriterios(r.parametros),
          ],
          const SizedBox(height: 20),
          IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Expanded(flex: 19, child: GiroTop10(r.top)),
              const SizedBox(width: 20),
              Expanded(flex: 10, child: GiroFinanceiro(r)),
            ]),
          ),
        ] else if (s.resumoStep == GiroSecaoStep.falha)
          _Erro(onRetry: () => _bloc.add(GiroEstoqueIniciou()))
        else
          const GiroEsqueleto(altura: 96, linhas: 1),
        const SizedBox(height: 20),
        _abas(s, desktop: true),
        const SizedBox(height: 16),
        _filtrosDesktop(s),
        const SizedBox(height: 16),
        _lista(s, desktop: true),
      ],
    );
  }

  Widget _abas(RelatorioGiroEstoqueState s, {required bool desktop}) {
    final totais = s.resumo?.totaisAbas ?? const {};
    if (!desktop) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: giroTinta.withValues(alpha: .18)),
        ),
        child: Row(children: [
          for (final a in AbaGiro.values)
            Expanded(
              child: InkWell(
                onTap: () => _bloc.add(GiroAbaAlterada(a)),
                child: Container(
                  height: 40,
                  alignment: Alignment.center,
                  color: s.aba == a ? giroAcentoEscuro : null,
                  child: Text(
                    const {AbaGiro.ranking: 'Ranking', AbaGiro.reposicao: 'Reposição', AbaGiro.parado: 'Parado'}[a]!,
                    style: giroCorpo(context, 12.5, cor: s.aba == a ? Colors.white : giroTinta),
                  ),
                ),
              ),
            ),
        ]),
      );
    }
    return Container(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: giroLinha))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        for (final a in AbaGiro.values)
          InkWell(
            key: ValueKey('aba_${a.name}'),
            onTap: () => _bloc.add(GiroAbaAlterada(a)),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 11),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 2, color: s.aba == a ? giroAcento : Colors.transparent),
                ),
              ),
              child: Row(children: [
                Text(nomeAba(a),
                    style: giroCorpo(context, 14,
                        cor: s.aba == a ? giroTinta : giroTinta.withValues(alpha: .6))),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  color: giroTinta.withValues(alpha: .07),
                  child: Text(fmtN(totais[a] ?? 0),
                      style: giroCorpo(context, 11.5, cor: giroTinta.withValues(alpha: .7))),
                ),
              ]),
            ),
          ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: [
            Text('VISÃO', style: context.sivTextos.rotulo.copyWith(fontSize: 11, letterSpacing: 1.6, color: giroApoio)),
            const SizedBox(width: 10),
            _Segmentos<String>(
              valores: const {'produto': 'Produto', 'variacao': 'Variação'},
              atual: s.filtro.visualizacao,
              onChanged: (v) => _bloc.add(GiroVisaoAlterada(v)),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _chipFiltro(String rotulo, int n, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: giroTinta.withValues(alpha: .16)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text('$rotulo: ${n == 0 ? 'Todas' : '$n'}', style: giroCorpo(context, 12.5)),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down, size: 14),
          ]),
        ),
      );

  Widget _campoBusca(String dica) => TextField(
        controller: _buscaController,
        onChanged: (_) => _debouncer.run(_emitirFiltro),
        style: giroCorpo(context, 12.5),
        decoration: InputDecoration(
          hintText: dica,
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          prefixIcon: const Icon(Icons.search, size: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: giroTinta.withValues(alpha: .18)),
          ),
        ),
      );

  Widget _filtrosDesktop(RelatorioGiroEstoqueState s) {
    final f = s.filtro;
    return Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
      SizedBox(width: 260, child: _campoBusca('Nome, código ou SKU')),
      for (final k in _seletores.keys)
        _chipFiltro(k, (_sel[k] ?? const []).length, () => _escolherSeletor(k)),
      _chipFiltro('Preço', f.precoMin != null || f.precoMax != null ? 1 : 0, _escolherPreco),
      for (final c in f.classificacoes)
        GiroChipClassificacao(
          classificacao: c,
          onRemover: () => _bloc.add(GiroClassificacaoLimpa()),
        ),
    ]);
  }

  // ------------------------------------------------------------------ lista

  bool _filtrosAtivos(FiltroGiroEstoque f) =>
      f.totalAtivos > 0 || f.classificacoes.isNotEmpty || (f.busca?.isNotEmpty ?? false);

  Widget _lista(RelatorioGiroEstoqueState s, {required bool desktop}) {
    final p = s.pagina;
    if (s.listaStep == GiroSecaoStep.falha && p == null) {
      return _Erro(onRetry: () => _bloc.add(GiroPaginaAlterada(s.page)));
    }
    if (p == null || (s.listaStep == GiroSecaoStep.carregando && p.items.isEmpty)) {
      return const GiroEsqueleto(altura: 52, linhas: 8);
    }
    if (p.items.isEmpty) {
      final filtrado = _filtrosAtivos(s.filtro);
      return _Vazio(
        titulo: filtrado
            ? 'Nenhum produto com esses filtros'
            : 'Nenhuma entrada de estoque neste período',
        descricao: filtrado ? null : 'Amplie o período para ver mais lotes.',
        onLimpar: filtrado ? _limparFiltros : null,
      );
    }
    final parametros = s.resumo?.parametros ?? const ParametrosGiro();
    final conteudo = desktop
        ? GiroTabela(
            aba: s.aba,
            visaoVariacao: s.filtro.visualizacao == 'variacao',
            pagina: p,
            ordenarPor: s.ordenarPor,
            ordem: s.ordem,
            variacoes: s.variacoes,
            abertos: s.abertos,
            carregandoVariacoes: s.carregandoVariacoes,
            parametros: parametros,
            onOrdenar: (c) => _bloc.add(GiroOrdenacaoAlterada(c)),
            onExpandir: (id) => _bloc.add(GiroLinhaExpandida(id)),
            onPagina: (n) => _bloc.add(GiroPaginaAlterada(n)),
          )
        : GiroCardsMobile(
            aba: s.aba,
            visaoVariacao: s.filtro.visualizacao == 'variacao',
            pagina: p,
            variacoes: s.variacoes,
            abertos: s.abertos,
            carregandoVariacoes: s.carregandoVariacoes,
            onExpandir: (id) => _bloc.add(GiroLinhaExpandida(id)),
            onPagina: (n) => _bloc.add(GiroPaginaAlterada(n)),
          );
    return Opacity(
      opacity: s.listaStep == GiroSecaoStep.carregando ? .5 : 1,
      child: conteudo,
    );
  }

  // ----------------------------------------------------------------- mobile

  Widget _mobile(RelatorioGiroEstoqueState s) {
    final r = s.resumo;
    final nFiltros = s.filtro.totalAtivos;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            for (final p in PeriodoGiro.values)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: InkWell(
                  onTap: () => _escolherPeriodo(p),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: s.filtro.periodo == p ? giroAcentoEscuro : Colors.white,
                      border: Border.all(
                        color: s.filtro.periodo == p ? giroAcentoEscuro : giroTinta.withValues(alpha: .18),
                      ),
                    ),
                    child: Text(p.label,
                        style: giroCorpo(context, 12.5,
                            cor: s.filtro.periodo == p ? Colors.white : giroTinta)),
                  ),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 14),
        if (r != null)
          GiroPainelMobile(
            resumo: r,
            selecionadas: s.filtro.classificacoes,
            onFaixa: (c) => _bloc.add(GiroClassificacaoSelecionada(c)),
          )
        else if (s.resumoStep == GiroSecaoStep.falha)
          _Erro(onRetry: () => _bloc.add(GiroEstoqueIniciou()))
        else
          const GiroEsqueleto(altura: 160, linhas: 1),
        const SizedBox(height: 14),
        _abas(s, desktop: false),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: SizedBox(height: 44, child: _campoBusca('Produto ou SKU'))),
          const SizedBox(width: 8),
          InkWell(
            onTap: _filtrosMobile,
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: giroTinta.withValues(alpha: .18)),
              ),
              child: Row(children: [
                const Icon(Icons.tune, size: 15),
                const SizedBox(width: 7),
                Text('Filtros${nFiltros > 0 ? ' ($nFiltros)' : ''}',
                    style: giroCorpo(context, 13)),
              ]),
            ),
          ),
        ]),
        if (s.filtro.classificacoes.isNotEmpty) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: GiroChipClassificacao(
              classificacao: s.filtro.classificacoes.first,
              onRemover: () => _bloc.add(GiroClassificacaoLimpa()),
            ),
          ),
        ],
        const SizedBox(height: 14),
        _lista(s, desktop: false),
      ],
    );
  }
}

class _CamposPreco extends StatelessWidget {
  final TextEditingController min;
  final TextEditingController max;
  const _CamposPreco({required this.min, required this.max});

  @override
  Widget build(BuildContext context) => Row(children: [
        for (final (c, r) in [(min, 'Preço mínimo'), (max, 'Preço máximo')])
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextField(
                controller: c,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: r, isDense: true, prefixText: 'R\$ '),
              ),
            ),
          ),
      ]);
}

class _Segmentos<T> extends StatelessWidget {
  final Map<T, String> valores;
  final T atual;
  final ValueChanged<T> onChanged;
  const _Segmentos({required this.valores, required this.atual, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(border: Border.all(color: giroTinta.withValues(alpha: .18))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          for (final e in valores.entries)
            InkWell(
              onTap: () => onChanged(e.key),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                color: atual == e.key ? giroAcentoEscuro : Colors.white,
                child: Text(e.value,
                    style: giroCorpo(context, 12.5,
                        cor: atual == e.key ? Colors.white : giroTinta)),
              ),
            ),
        ]),
      );
}

class _SeletorPeriodo extends StatelessWidget {
  final PeriodoGiro atual;
  final ValueChanged<PeriodoGiro> onChanged;
  const _SeletorPeriodo({required this.atual, required this.onChanged});

  @override
  Widget build(BuildContext context) => _Segmentos<PeriodoGiro>(
        valores: {for (final p in PeriodoGiro.values) p: p.label},
        atual: atual,
        onChanged: onChanged,
      );
}

class _Erro extends StatelessWidget {
  final VoidCallback onRetry;
  const _Erro({required this.onRetry});

  @override
  Widget build(BuildContext context) => GiroPainel(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          Text('Não foi possível carregar o relatório.', style: giroCorpo(context, 14)),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar de novo'),
          ),
        ]),
      );
}

class _Vazio extends StatelessWidget {
  final String titulo;
  final String? descricao;
  final VoidCallback? onLimpar;
  const _Vazio({required this.titulo, this.descricao, this.onLimpar});

  @override
  Widget build(BuildContext context) => GiroPainel(
        padding: const EdgeInsets.all(32),
        child: Column(children: [
          Text(titulo, style: context.sivTextos.secao.copyWith(fontSize: 18)),
          if (descricao != null) ...[
            const SizedBox(height: 6),
            Text(descricao!, style: giroCorpo(context, 13, cor: giroApoio)),
          ],
          if (onLimpar != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onLimpar, child: const Text('Limpar filtros')),
          ],
        ]),
      );
}

/// Esqueleto de carregamento (painel ou linhas da tabela).
class GiroEsqueleto extends StatelessWidget {
  final double altura;
  final int linhas;
  const GiroEsqueleto({super.key, required this.altura, required this.linhas});

  @override
  Widget build(BuildContext context) => GiroPainel(
        child: Column(children: [
          for (var i = 0; i < linhas; i++)
            Container(
              height: altura,
              margin: const EdgeInsets.all(6),
              color: giroTinta.withValues(alpha: .05),
            ),
        ]),
      );
}
