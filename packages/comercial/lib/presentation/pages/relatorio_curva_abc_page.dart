import 'package:comercial/domain/models/relatorios.dart';
import 'package:comercial/presentation/blocs/relatorio_curva_abc_bloc/relatorio_curva_abc_bloc.dart';
import 'package:comercial/presentation/relatorios/pdf/relatorio_pdf_exporter.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
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

String _fmtData(String iso) {
  if (iso.isEmpty) return '-';
  final p = iso.split('-');
  return p.length == 3 ? '${p[2]}/${p[1]}/${p[0]}' : iso;
}

(String, String) _mesAtual() {
  final now = DateTime.now();
  final ultimo = DateTime(now.year, now.month + 1, 0).day;
  final m = now.month.toString().padLeft(2, '0');
  return (
    '${now.year}-$m-01',
    '${now.year}-$m-${ultimo.toString().padLeft(2, '0')}',
  );
}

String _isoDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class RelatorioCurvaAbcPage extends StatefulWidget {
  const RelatorioCurvaAbcPage({super.key});

  @override
  State<RelatorioCurvaAbcPage> createState() => _RelatorioCurvaAbcPageState();
}

class _RelatorioCurvaAbcPageState extends State<RelatorioCurvaAbcPage> {
  late final RelatorioCurvaAbcBloc _bloc;
  late String _dataInicial;
  late String _dataFinal;
  String _agruparPor = 'produto';
  bool _exportandoPdf = false;
  List<int> _referenciaIdsSelecionados = [];
  List<int> _categoriaIdsSelecionados = [];

  @override
  void initState() {
    super.initState();
    final (ini, fim) = _mesAtual();
    _dataInicial = ini;
    _dataFinal = fim;
    _bloc = sl<RelatorioCurvaAbcBloc>()
      ..add(RelatorioCurvaAbcCarregar(dataInicial: ini, dataFinal: fim));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _aplicar({int page = 1}) {
    _bloc.add(RelatorioCurvaAbcCarregar(
      dataInicial: _dataInicial,
      dataFinal: _dataFinal,
            page: page,
      agruparPor: _agruparPor,
      referenciaIds: _referenciaIdsSelecionados,
      categoriaIds: _categoriaIdsSelecionados,
    ));
  }

  void _onAgruparPorAlterado(String valor) {
    if (_agruparPor == valor) return;
    setState(() {
      _agruparPor = valor;
      _referenciaIdsSelecionados = [];
      _categoriaIdsSelecionados = [];
    });
    _aplicar(page: 1);
  }

  void _onReferenciaSelecionada(List<Referencia> referencias) {
    setState(() {
      _referenciaIdsSelecionados = referencias
          .map((r) => r.id)
          .whereType<int>()
          .toList();
    });
    _aplicar(page: 1);
  }

  void _onCategoriaSelecionada(List<Categoria> categorias) {
    setState(() {
      _categoriaIdsSelecionados = categorias
          .map((c) => c.id)
          .whereType<int>()
          .toList();
    });
    _aplicar(page: 1);
  }

  Future<void> _abrirFiltroPeriodo() async {
    var dataInicial = _dataInicial;
    var dataFinal = _dataFinal;

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filtrar por período',
                    style: Theme.of(sheetContext).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ActionChip(
                          label: const Text('Este mês'),
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            final (ini, fim) = _mesAtual();
                            setSheetState(() {
                              dataInicial = ini;
                              dataFinal = fim;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        ActionChip(
                          label: const Text('30 dias'),
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            final fim = DateTime.now();
                            final ini = fim.subtract(const Duration(days: 29));
                            setSheetState(() {
                              dataInicial = _isoDate(ini);
                              dataFinal = _isoDate(fim);
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        ActionChip(
                          label: const Text('90 dias'),
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            final fim = DateTime.now();
                            final ini = fim.subtract(const Duration(days: 89));
                            setSheetState(() {
                              dataInicial = _isoDate(ini);
                              dataFinal = _isoDate(fim);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _DateBtn(
                          label: 'De',
                          date: _fmtData(dataInicial),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: sheetContext,
                              initialDate:
                                  DateTime.tryParse(dataInicial) ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (picked == null) return;
                            setSheetState(() => dataInicial = _isoDate(picked));
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _DateBtn(
                          label: 'Até',
                          date: _fmtData(dataFinal),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: sheetContext,
                              initialDate:
                                  DateTime.tryParse(dataFinal) ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (picked == null) return;
                            setSheetState(() => dataFinal = _isoDate(picked));
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: const Text('Aplicar'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (!mounted) return;
    setState(() {
      _dataInicial = dataInicial;
      _dataFinal = dataFinal;
    });
    _aplicar(page: 1);
  }

  Future<void> _abrirFiltroReferenciaOuCategoria() async {
    final porReferencia = _agruparPor == 'produto';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
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
                  porReferencia ? 'Filtrar por referência' : 'Filtrar por categoria',
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                if (porReferencia)
                  ReferenciaSeletor(
                    key: const ValueKey('referencia-seletor-curva-abc'),
                    modo: ReferenciaSeletorModo.multipla,
                    permitirCadastro: false,
                    onReferenciaChanged: _onReferenciaSelecionada,
                  )
                else
                  CategoriaSeletor(
                    key: const ValueKey('categoria-seletor-curva-abc'),
                    modo: CategoriaSeletorModo.multipla,
                    onCategoriaChanged: _onCategoriaSelecionada,
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
  }

  void _mostrarComoFunciona() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _ComoFuncionaSheet(),
    );
  }

  String _rotuloAgrupar(String v) => switch (v) {
    'referencia' => 'Referência',
    'categoria' => 'Categoria',
    _ => 'Produto',
  };

  Future<void> _exportar(RelatorioCurvaAbcState state) async {
    setState(() => _exportandoPdf = true);
    await RelatorioPdfExporter.exportarCurvaAbc(
      state.dados!,
      state.dataInicial,
      state.dataFinal,
    );
    if (mounted) setState(() => _exportandoPdf = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RelatorioCurvaAbcBloc>.value(
      value: _bloc,
      child: BlocBuilder<RelatorioCurvaAbcBloc, RelatorioCurvaAbcState>(
        builder: (context, state) {
          final d = state.dados;
          final pronto = state.step == RelatorioCurvaAbcStep.sucesso && d != null;
          final falha = state.step == RelatorioCurvaAbcStep.falha;
          return Scaffold(
            body: SafeArea(
              child: RelatorioScaffold(
                titulo: 'Curva ABC',
                carregando: !pronto && !falha,
                erro: falha
                    ? (state.erro ?? 'Falha ao carregar curva ABC.')
                    : null,
                onTentarDeNovo: _aplicar,
                vazio: pronto && d.items.isEmpty,
                filtros: [
                  RelatorioFiltroChip(
                    rotulo: 'Período',
                    valor:
                        '${_fmtData(_dataInicial)} - ${_fmtData(_dataFinal)}',
                    onTap: _abrirFiltroPeriodo,
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Agrupar por',
                    onSelected: _onAgruparPorAlterado,
                    itemBuilder: (_) => [
                      for (final k in const ['produto', 'referencia', 'categoria'])
                        PopupMenuItem(value: k, child: Text(_rotuloAgrupar(k))),
                    ],
                    child: IgnorePointer(
                      child: RelatorioFiltroChip(
                        rotulo: 'Agrupar',
                        valor: _rotuloAgrupar(_agruparPor),
                        onTap: () {},
                      ),
                    ),
                  ),
                  if (_agruparPor == 'produto')
                    RelatorioFiltroChip(
                      rotulo: 'Referência',
                      valor: _referenciaIdsSelecionados.isEmpty
                          ? 'Todas'
                          : '${_referenciaIdsSelecionados.length}',
                      onTap: _abrirFiltroReferenciaOuCategoria,
                    )
                  else if (_agruparPor == 'referencia')
                    RelatorioFiltroChip(
                      rotulo: 'Categoria',
                      valor: _categoriaIdsSelecionados.isEmpty
                          ? 'Todas'
                          : '${_categoriaIdsSelecionados.length}',
                      onTap: _abrirFiltroReferenciaOuCategoria,
                    ),
                ],
                acoes: [
                  IconButton(
                    icon: const Icon(Icons.help_outline),
                    tooltip: 'Como funciona a curva ABC',
                    onPressed: _mostrarComoFunciona,
                  ),
                  if (pronto)
                    _exportandoPdf
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : OutlinedButton.icon(
                            icon: const Icon(Icons.picture_as_pdf_outlined,
                                size: 18),
                            label: const Text('PDF'),
                            onPressed: () => _exportar(state),
                          ),
                ],
                kpis: pronto && d.resumo != null
                    ? [
                        for (final c in d.resumo!.classes)
                          _ClasseCard(classe: c),
                      ]
                    : const [],
                corpo: pronto
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _Tabela(
                            itens: d.items,
                            inicio: (state.page - 1) * d.meta.itemsPerPage,
                          ),
                          if (state.totalPages > 1) _Paginacao(
                            page: state.page,
                            totalPages: state.totalPages,
                            onPagina: (p) => _aplicar(page: p),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ClasseCard extends StatelessWidget {
  final RelatorioCurvaAbcClasse classe;
  const _ClasseCard({required this.classe});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final mobile = relatorioMobile(context);
    final destaque = classe.classe == 'A';
    final pct = '${classe.percentualFaturamento.round()}%';
    final rotulo = mobile
        ? 'CLASSE ${classe.classe}'
        : 'CLASSE ${classe.classe} · ${classe.percentualItens.round()}% dos itens';
    final valor = mobile
        ? '$pct do fat.'
        : '$pct do faturamento · ${_fmtMoedaInt(classe.valorTotal)}';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: mobile ? 14 : 18,
        vertical: mobile ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: cores.superficie,
        border: Border.all(color: destaque ? cores.aco : cores.hairline),
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            rotulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textos.apoio.copyWith(
              fontSize: mobile ? 9.5 : 10.5,
              letterSpacing: mobile ? 1.1 : 1.47,
              color: destaque ? cores.acoAtivo : cores.textoApoio,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textos.titulo.copyWith(
              fontSize: mobile ? 15 : 19,
              color: cores.tinta,
            ),
          ),
        ],
      ),
    );
  }
}

String _fmtMoedaInt(double v) => _fmtMoeda(v).replaceAll(RegExp(r',\d{2}$'), '');

class _Tabela extends StatelessWidget {
  final List<RelatorioCurvaAbcItem> itens;
  final int inicio;
  const _Tabela({required this.itens, required this.inicio});

  static String _nome(RelatorioCurvaAbcItem i) =>
      i.referenciaNome ?? i.categoriaNome ?? 'Sem categoria';

  static String _pos(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    final cores = context.sivColors;
    return RelatorioTabela<RelatorioCurvaAbcItem>(
      colunas: const [
        RelatorioColuna(id: 'pos', titulo: '#', ordenavel: false),
        RelatorioColuna(id: 'produto', titulo: 'Produto', ordenavel: false, flex: 5),
        RelatorioColuna(
            id: 'faturamento', titulo: 'Faturamento', numerica: true, ordenavel: false, flex: 2),
        RelatorioColuna(
            id: 'acum', titulo: '% acum.', numerica: true, ordenavel: false, flex: 2),
        RelatorioColuna(id: 'classe', titulo: 'Classe', ordenavel: false),
      ],
      itens: itens,
      celulas: (context, i) {
        final idx = itens.indexOf(i);
        final a = i.classeAbc == 'A';
        final detalhe = [i.corNome, i.tamanhoNome].whereType<String>().join(' · ');
        return [
          Text(_pos(inicio + idx + 1),
              style: textos.apoio.copyWith(color: cores.textoApoio)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _nome(i),
                style: textos.corpo.copyWith(
                  fontWeight: a ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
              if (detalhe.isNotEmpty)
                Text(detalhe,
                    style: textos.apoio.copyWith(color: cores.textoApoio)),
            ],
          ),
          Text(_fmtMoeda(i.valorTotalVendido), style: textos.corpo),
          Text('${i.percentualAcumulado.toStringAsFixed(1).replaceAll('.', ',')}%',
              style: textos.corpo),
          _TagClasse(classe: i.classeAbc),
        ];
      },
      itemMobile: (context, i) {
        final idx = itens.indexOf(i);
        final detalhe = [i.corNome, i.tamanhoNome].whereType<String>().join(' · ');
        return RelatorioItemMobile(
          titulo: '${_pos(inicio + idx + 1)}  ${_nome(i)}',
          apoio: [
            if (detalhe.isNotEmpty) detalhe,
            '${i.percentualAcumulado.toStringAsFixed(1).replaceAll('.', ',')}% acum.',
            'Classe ${i.classeAbc}',
          ],
          valor: _fmtMoeda(i.valorTotalVendido),
        );
      },
    );
  }
}

class _TagClasse extends StatelessWidget {
  final String classe;
  const _TagClasse({required this.classe});

  @override
  Widget build(BuildContext context) {
    final c = context.sivColors;
    final (fundo, texto) = switch (classe) {
      'A' => (c.acoEscuro, c.textoSobreEscuroTitulo),
      'B' => (c.classeBTagFundo, c.classeBTagTexto),
      _ => (c.classeCTagFundo, c.classeCTagTexto),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
      ),
      child: Text(
        classe,
        style: context.sivTextos.apoio
            .copyWith(color: texto, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _Paginacao extends StatelessWidget {
  final int page;
  final int totalPages;
  final ValueChanged<int> onPagina;
  const _Paginacao({
    required this.page,
    required this.totalPages,
    required this.onPagina,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.chevron_left),
              label: const Text('Anterior'),
              onPressed: page > 1 ? () => onPagina(page - 1) : null,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('$page/$totalPages',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            TextButton.icon(
              icon: const Icon(Icons.chevron_right),
              label: const Text('Próxima'),
              onPressed: page < totalPages ? () => onPagina(page + 1) : null,
            ),
          ],
        ),
      );
}

class _DateBtn extends StatelessWidget {
  final String label;
  final String date;
  final VoidCallback onTap;
  const _DateBtn(
      {required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Text('$label: ',
                  style: TextStyle(
                      fontSize: 12, color: context.sivColors.textoApoio)),
              Expanded(
                child: Text(date,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
              ),
              const Icon(Icons.calendar_today_outlined, size: 16),
            ],
          ),
        ),
      );
}

class _ComoFuncionaSheet extends StatelessWidget {
  const _ComoFuncionaSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.bar_chart, size: 22),
                  const SizedBox(width: 8),
                  Text('Como funciona a Curva ABC',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'A curva ABC separa seus produtos por importância no faturamento, '
                'pra você saber onde focar atenção e estoque.',
              ),
              const SizedBox(height: 16),
              _ComoFuncionaItem(
                cor: context.sivColors.acoEscuro,
                titulo: 'Classe A',
                texto:
                    'Poucos itens, mas respondem por 80% do faturamento. São os campeões de venda — nunca deixe faltar em estoque.',
              ),
              _ComoFuncionaItem(
                cor: context.sivColors.classeBTagTexto,
                titulo: 'Classe B',
                texto:
                    'Itens que somam mais 15% do faturamento (de 80% a 95% acumulado). Bons, mas não são prioridade máxima.',
              ),
              _ComoFuncionaItem(
                cor: context.sivColors.classeCBarra,
                titulo: 'Classe C',
                texto:
                    'O restante, apenas 5% do faturamento — geralmente a maioria dos itens do catálogo. Vendem pouco: candidatos a promoção, queima de estoque ou corte.',
              ),
              const Divider(height: 28),
              Text('O que cada dado do card significa',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const _ComoFuncionaCampo(
                titulo: 'Quantidade vendida e valor total vendido',
                texto:
                    'Quanto foi vendido do item (ou da referência, se você estiver agrupando por referência) dentro do período filtrado.',
              ),
              const _ComoFuncionaCampo(
                titulo: '% de participação',
                texto:
                    'Quanto aquele item sozinho representa do faturamento total do período — quanto maior, mais ele pesa nas suas vendas.',
              ),
              const _ComoFuncionaCampo(
                titulo: '% acumulado',
                texto:
                    'Soma das participações de todos os itens até aquele, na lista ordenada do maior pro menor faturamento. É esse número que decide se o item é A, B ou C.',
              ),
              const _ComoFuncionaCampo(
                titulo: 'Produto x Referência x Categoria',
                texto:
                    'Produto: cada cor/tamanho conta separado. Referência: soma todas as cores e tamanhos de uma referência num item só. Categoria: soma todas as referências de uma categoria num item só — útil pra ver o desempenho do grupo de produtos como um todo.',
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Entendi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComoFuncionaItem extends StatelessWidget {
  final Color cor;
  final String titulo;
  final String texto;
  const _ComoFuncionaItem(
      {required this.cor, required this.titulo, required this.texto});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    TextSpan(
                        text: '$titulo: ',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: texto),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}

class _ComoFuncionaCampo extends StatelessWidget {
  final String titulo;
  final String texto;
  const _ComoFuncionaCampo({required this.titulo, required this.texto});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(texto,
                style: TextStyle(
                    fontSize: 12.5, color: context.sivColors.textoApoio)),
          ],
        ),
      );
}
