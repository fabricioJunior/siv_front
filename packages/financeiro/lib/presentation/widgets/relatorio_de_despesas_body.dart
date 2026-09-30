import 'package:core/injecoes.dart';
import 'package:core/sessao.dart';
import 'package:financeiro/domain/models/categoria_despesa.dart';
import 'package:financeiro/domain/models/despesa.dart';
import 'package:financeiro/domain/utils/resumo_de_despesas.dart';
import 'package:financeiro/presentation/utils/formatadores.dart';
import 'package:financeiro/presentation/widgets/card_blueprint.dart';
import 'package:financeiro/use_cases.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

const _cores = [
  Color(0xFF5980A6),
  Color(0xFFE07A5F),
  Color(0xFF81B29A),
  Color(0xFFF2CC8F),
  Color(0xFF9B72AA),
  Color(0xFF3D9970),
  Color(0xFFD1495B),
  Color(0xFF8D99AE),
];
const _maxFatias = 7;

class RelatorioDeDespesasBody extends StatefulWidget {
  const RelatorioDeDespesasBody({super.key});

  @override
  State<RelatorioDeDespesasBody> createState() =>
      _RelatorioDeDespesasBodyState();
}

class _RelatorioDeDespesasBodyState extends State<RelatorioDeDespesasBody> {
  late DateTime _inicio;
  late DateTime _fim;
  final Set<int> _categoriaIds = {};
  List<CategoriaDespesa> _categorias = const [];
  List<Despesa> _despesas = const [];
  bool _separarTodas = false;
  bool _outrasAberto = false;
  bool _carregando = true;
  bool _falhou = false;

  int get _empresaId => sl<IAcessoGlobalSessao>().empresaIdDaSessao ?? 0;

  @override
  void initState() {
    super.initState();
    final hoje = DateTime.now();
    _inicio = DateTime(hoje.year, hoje.month, 1);
    _fim = DateTime(hoje.year, hoje.month + 1, 0);
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _falhou = false;
    });
    try {
      final resultados = await Future.wait([
        sl<RecuperarCategoriasDespesa>().call(empresaId: _empresaId),
        // dataFinal +1 dia: o backend pode tratar o fim como meia-noite; o
        // corte exato do período é refeito em `despesasDoRelatorio`.
        sl<RecuperarDespesas>().call(
          empresaId: _empresaId,
          dataInicial: _inicio,
          dataFinal: _fim.add(const Duration(days: 1)),
        ),
      ]);
      if (!mounted) return;
      setState(() {
        _categorias = resultados[0] as List<CategoriaDespesa>;
        _despesas = resultados[1] as List<Despesa>;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _carregando = false;
        _falhou = true;
      });
    }
  }

  Future<void> _escolherPeriodo() async {
    final escolhido = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(DateTime.now().year + 2, 12, 31),
      initialDateRange: DateTimeRange(start: _inicio, end: _fim),
    );
    if (escolhido == null) return;
    _inicio = escolhido.start;
    _fim = escolhido.end;
    _carregar();
  }

  String _nomeCategoria(int id) {
    for (final c in _categorias) {
      if (c.id == id) return c.nome;
    }
    return 'Categoria $id';
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (_falhou) {
      return Center(
        child: TextButton(
          onPressed: _carregar,
          child: const Text('Falha ao carregar. Tentar de novo'),
        ),
      );
    }

    final despesas = despesasDoRelatorio(
      _despesas,
      inicio: _inicio,
      fim: _fim,
      categoriaIds: _categoriaIds,
    );
    final total = despesas.fold<double>(0, (s, d) => s + d.valor);
    final porDia = totaisPorDia(despesas, inicio: _inicio, fim: _fim);
    final porCategoria = totaisPorCategoria(despesas);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _filtros(),
        const SizedBox(height: 16),
        Text(
          '${formatarReais(total)}  ·  ${despesas.length} lançamentos',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        if (despesas.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: Text('Nenhum gasto no período.')),
          )
        else ...[
          LayoutBuilder(
            builder: (context, c) {
              final graficoDia = _cardGraficoPorDia(porDia);
              final graficoCategoria = _cardPizza(porCategoria, total);
              if (c.maxWidth < 900) {
                return Column(children: [
                  graficoDia,
                  const SizedBox(height: 16),
                  graficoCategoria,
                ]);
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: graficoDia),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: graficoCategoria),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          _lista(despesas),
        ],
      ],
    );
  }

  List<CategoriaDespesa> get _categoriasAtivas =>
      _categorias.where((c) => !c.inativa && c.id != null).toList();

  Future<void> _escolherCategorias() async {
    final escolhidas = await showModalBottomSheet<Set<int>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      // Em tela larga vira um painel centralizado, não uma folha esticada.
      constraints: const BoxConstraints(maxWidth: 520),
      builder: (_) => _SeletorDeCategorias(
        categorias: _categoriasAtivas,
        selecionadas: _categoriaIds,
      ),
    );
    if (escolhidas == null) return;
    setState(() {
      _categoriaIds
        ..clear()
        ..addAll(escolhidas);
    });
  }

  Widget _filtros() {
    String data(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    final nomes = [
      for (final c in _categoriasAtivas)
        if (_categoriaIds.contains(c.id)) c.nome,
    ];
    final rotuloCategorias = nomes.isEmpty
        ? 'Todas as categorias'
        : nomes.length == 1
            ? nomes.first
            : '${nomes.length} categorias';
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        OutlinedButton.icon(
          onPressed: _escolherPeriodo,
          icon: const Icon(Icons.date_range, size: 18),
          label: Text('${data(_inicio)} a ${data(_fim)}'),
        ),
        OutlinedButton.icon(
          onPressed: _escolherCategorias,
          icon: const Icon(Icons.category_outlined, size: 18),
          label: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Text(rotuloCategorias,
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ),
        if (_categoriaIds.isNotEmpty)
          TextButton(
            onPressed: () => setState(_categoriaIds.clear),
            child: const Text('Limpar'),
          ),
      ],
    );
  }

  Widget _cardGraficoPorDia(List<(DateTime, double)> porDia) {
    final maximo = porDia.fold<double>(0, (m, e) => e.$2 > m ? e.$2 : m);
    final passo = (porDia.length / 8).ceil().clamp(1, 31);
    return CardBlueprint(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Gastos por dia'),
          const SizedBox(height: 16),
          SizedBox(
            height: 260,
            child: BarChart(
              BarChartData(
                maxY: maximo * 1.15,
                gridData: const FlGridData(drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 56,
                      getTitlesWidget: (v, meta) => v == meta.max
                          ? const SizedBox.shrink()
                          : Text(formatarReaisCompacto(v),
                              style: const TextStyle(fontSize: 10)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i % passo != 0 || i >= porDia.length) {
                          return const SizedBox.shrink();
                        }
                        return Text('${porDia[i].$1.day}',
                            style: const TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, _, rod, __) {
                      final (dia, valor) = porDia[group.x];
                      return BarTooltipItem(
                        '${dia.day}/${dia.month}\n${formatarReais(valor)}',
                        const TextStyle(color: Colors.white, fontSize: 12),
                      );
                    },
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < porDia.length; i++)
                    BarChartGroupData(x: i, barRods: [
                      BarChartRodData(
                        toY: porDia[i].$2,
                        color: _cores[0],
                        width: porDia.length > 20 ? 6 : 12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardPizza(List<(int, double)> porCategoria, double total) {
    // Fatias demais viram ilegíveis: por padrão as menores viram "Outras",
    // com opção de separar todas.
    final agrupar = !_separarTodas && porCategoria.length > _maxFatias;
    final principais = agrupar ? porCategoria.take(_maxFatias) : porCategoria;
    final outras = agrupar
        ? [for (final e in porCategoria.skip(_maxFatias)) (_nomeCategoria(e.$1), e.$2)]
        : const <(String, double)>[];
    final fatias = <(String, double)>[
      for (final e in principais) (_nomeCategoria(e.$1), e.$2),
      if (outras.isNotEmpty)
        ('Outras (${outras.length} categorias)', outras.fold<double>(0, (s, e) => s + e.$2)),
    ];
    final apoio = Theme.of(context).textTheme.bodySmall;
    return CardBlueprint(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Gastos por categoria'),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  for (var i = 0; i < fatias.length; i++)
                    PieChartSectionData(
                      value: fatias[i].$2,
                      color: _cores[i % _cores.length],
                      radius: 60,
                      title: fatias[i].$2 / total >= 0.06
                          ? '${(fatias[i].$2 / total * 100).round()}%'
                          : '',
                      titleStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < fatias.length; i++) ...[
            InkWell(
              onTap: outras.isNotEmpty && i == fatias.length - 1
                  ? () => setState(() => _outrasAberto = !_outrasAberto)
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Container(
                        width: 10,
                        height: 10,
                        color: _cores[i % _cores.length]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(fatias[i].$1,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    Text(formatarReais(fatias[i].$2)),
                    if (outras.isNotEmpty && i == fatias.length - 1)
                      Icon(_outrasAberto ? Icons.expand_less : Icons.expand_more,
                          size: 18),
                  ],
                ),
              ),
            ),
            if (outras.isNotEmpty && i == fatias.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 18, bottom: 4),
                child: _outrasAberto
                    ? Column(
                        children: [
                          for (final o in outras)
                            Row(children: [
                              Expanded(
                                child: Text(o.$1,
                                    style: apoio,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ),
                              Text(formatarReais(o.$2), style: apoio),
                            ]),
                        ],
                      )
                    : Text(
                        'Inclui: ${outras.map((o) => o.$1).join(', ')}',
                        style: apoio,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
          ],
          if (porCategoria.length > _maxFatias)
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text('Mostrar todas as categorias na pizza'),
              value: _separarTodas,
              onChanged: (v) => setState(() => _separarTodas = v),
            ),
        ],
      ),
    );
  }

  Widget _lista(List<Despesa> despesas) {
    return CardBlueprint(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (final d in despesas)
            ListTile(
              dense: true,
              title: Text(d.descricao, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(
                '${d.dataPagamento!.day.toString().padLeft(2, '0')}/'
                '${d.dataPagamento!.month.toString().padLeft(2, '0')}  ·  '
                '${_nomeCategoria(d.categoriaId)}'
                '${d.status == StatusDespesa.pendente ? '  ·  pendente' : ''}',
              ),
              trailing: Text(formatarReais(d.valor)),
            ),
        ],
      ),
    );
  }
}

/// Folha com busca e caixas de seleção -- no celular sobe de baixo, em tela
/// larga fica centralizada. Só aplica ao confirmar.
class _SeletorDeCategorias extends StatefulWidget {
  final List<CategoriaDespesa> categorias;
  final Set<int> selecionadas;

  const _SeletorDeCategorias({
    required this.categorias,
    required this.selecionadas,
  });

  @override
  State<_SeletorDeCategorias> createState() => _SeletorDeCategoriasState();
}

class _SeletorDeCategoriasState extends State<_SeletorDeCategorias> {
  late final Set<int> _marcadas = {...widget.selecionadas};
  String _busca = '';

  @override
  Widget build(BuildContext context) {
    final visiveis = [
      for (final c in widget.categorias)
        if (c.nome.toLowerCase().contains(_busca.toLowerCase())) c,
    ];
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.75,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Categorias',
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  TextButton(
                    onPressed: () => setState(_marcadas.clear),
                    child: const Text('Limpar'),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _marcadas.addAll(
                        [for (final c in visiveis) c.id!])),
                    child: const Text('Todas'),
                  ),
                ],
              ),
            ),
            if (widget.categorias.length > 6)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Buscar categoria',
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _busca = v),
                ),
              ),
            Expanded(
              child: ListView(
                children: [
                  for (final c in visiveis)
                    CheckboxListTile(
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(c.nome),
                      value: _marcadas.contains(c.id),
                      onChanged: (v) => setState(() =>
                          v == true ? _marcadas.add(c.id!) : _marcadas.remove(c.id!)),
                    ),
                  if (visiveis.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: Text('Nenhuma categoria encontrada.')),
                    ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, _marcadas),
                    child: Text(_marcadas.isEmpty
                        ? 'Aplicar (todas)'
                        : 'Aplicar (${_marcadas.length})'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
