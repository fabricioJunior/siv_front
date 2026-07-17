import 'package:comercial/presentation/blocs/relatorio_curva_abc_bloc/relatorio_curva_abc_bloc.dart';
import 'package:comercial/presentation/relatorios/pdf/relatorio_pdf_exporter.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation/debouncer.dart';
import 'package:flutter/material.dart';

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
  final _buscaController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 380);

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
    _debouncer.cancel();
    _buscaController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _onBuscaAlterada(String valor) {
    _debouncer.run(() {
      final busca = valor.trim();
      _bloc.add(RelatorioCurvaAbcCarregar(
        dataInicial: _dataInicial,
        dataFinal: _dataFinal,
        busca: busca.isEmpty ? null : busca,
        page: 1,
        agruparPor: _agruparPor,
      ));
    });
  }

  Future<void> _selecionarData(bool isInicial) async {
    final initial = DateTime.tryParse(isInicial ? _dataInicial : _dataFinal);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked == null) return;
    setState(() {
      if (isInicial) {
        _dataInicial = _isoDate(picked);
      } else {
        _dataFinal = _isoDate(picked);
      }
    });
  }

  void _aplicar({int page = 1}) {
    final busca = _buscaController.text.trim();
    _bloc.add(RelatorioCurvaAbcCarregar(
      dataInicial: _dataInicial,
      dataFinal: _dataFinal,
      busca: busca.isEmpty ? null : busca,
      page: page,
      agruparPor: _agruparPor,
    ));
  }

  void _onAgruparPorAlterado(String valor) {
    if (_agruparPor == valor) return;
    setState(() => _agruparPor = valor);
    _aplicar(page: 1);
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RelatorioCurvaAbcBloc>.value(
      value: _bloc,
      child: BlocBuilder<RelatorioCurvaAbcBloc, RelatorioCurvaAbcState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Curva ABC de Produtos'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.help_outline),
                  tooltip: 'Como funciona a curva ABC',
                  onPressed: _mostrarComoFunciona,
                ),
                if (state.step == RelatorioCurvaAbcStep.sucesso &&
                    state.dados != null)
                  _exportandoPdf
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.picture_as_pdf_outlined),
                          tooltip: 'Exportar PDF',
                          onPressed: () async {
                            setState(() => _exportandoPdf = true);
                            await RelatorioPdfExporter.exportarCurvaAbc(
                              state.dados!,
                              state.dataInicial,
                              state.dataFinal,
                            );
                            if (mounted) setState(() => _exportandoPdf = false);
                          },
                        ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                // Filtros
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Filtros',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              ActionChip(
                                label: const Text('Este mês'),
                                visualDensity: VisualDensity.compact,
                                onPressed: () {
                                  final (ini, fim) = _mesAtual();
                                  setState(() {
                                    _dataInicial = ini;
                                    _dataFinal = fim;
                                  });
                                  _aplicar();
                                },
                              ),
                              const SizedBox(width: 8),
                              ActionChip(
                                label: const Text('30 dias'),
                                visualDensity: VisualDensity.compact,
                                onPressed: () {
                                  final fim = DateTime.now();
                                  final ini =
                                      fim.subtract(const Duration(days: 29));
                                  setState(() {
                                    _dataInicial = _isoDate(ini);
                                    _dataFinal = _isoDate(fim);
                                  });
                                  _aplicar();
                                },
                              ),
                              const SizedBox(width: 8),
                              ActionChip(
                                label: const Text('90 dias'),
                                visualDensity: VisualDensity.compact,
                                onPressed: () {
                                  final fim = DateTime.now();
                                  final ini =
                                      fim.subtract(const Duration(days: 89));
                                  setState(() {
                                    _dataInicial = _isoDate(ini);
                                    _dataFinal = _isoDate(fim);
                                  });
                                  _aplicar();
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _DateBtn(
                                label: 'De',
                                date: _fmtData(_dataInicial),
                                onTap: () => _selecionarData(true),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _DateBtn(
                                label: 'Até',
                                date: _fmtData(_dataFinal),
                                onTap: () => _selecionarData(false),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(
                                value: 'produto',
                                label: Text('Produto'),
                                icon: Icon(Icons.checkroom_outlined, size: 16),
                              ),
                              ButtonSegment(
                                value: 'referencia',
                                label: Text('Referência'),
                                icon: Icon(Icons.style_outlined, size: 16),
                              ),
                              ButtonSegment(
                                value: 'categoria',
                                label: Text('Categoria'),
                                icon: Icon(Icons.category_outlined, size: 16),
                              ),
                            ],
                            selected: {_agruparPor},
                            onSelectionChanged: (selecao) =>
                                _onAgruparPorAlterado(selecao.first),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _buscaController,
                          onChanged: _onBuscaAlterada,
                          decoration: InputDecoration(
                            hintText: 'Buscar por referência ou código...',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            isDense: true,
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () {
                                _buscaController.clear();
                                _onBuscaAlterada('');
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onSubmitted: (_) => _aplicar(),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _aplicar,
                            icon: const Icon(Icons.search),
                            label: const Text('Consultar'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                if (state.step == RelatorioCurvaAbcStep.carregando)
                  const _EstadoCard(
                      titulo: 'Carregando curva ABC',
                      descricao: 'Classificando produtos...',
                      loading: true)
                else if (state.step == RelatorioCurvaAbcStep.falha)
                  _EstadoCard(
                    titulo: 'Falha ao carregar',
                    descricao: state.erro ?? '',
                    onRetry: _aplicar,
                  )
                else if (state.step == RelatorioCurvaAbcStep.inicial)
                  const _EstadoCard(
                    titulo: 'Aplique o filtro',
                    descricao: 'Selecione o período e toque em Consultar.',
                  )
                else if (state.dados != null) ...[
                  _ResumoAbcCard(
                    totalItems: state.dados!.meta.totalItems,
                    itens: state.dados!.items,
                  ),
                  const SizedBox(height: 16),
                  _CurvaAbcVisual(itens: state.dados!.items),
                  const SizedBox(height: 16),
                  // Legenda ABC
                  Row(
                    children: [
                      Tooltip(
                        message:
                            'Classe A: os itens que, somados, já respondem por 80% do faturamento do período. São os mais importantes — evite ruptura de estoque.',
                        child: _LegendaChip(
                            cor: Colors.green, label: 'A — até 80%'),
                      ),
                      const SizedBox(width: 8),
                      Tooltip(
                        message:
                            'Classe B: itens que somam entre 80% e 95% do faturamento acumulado. Relevantes, mas não prioridade máxima.',
                        child: _LegendaChip(
                            cor: Colors.amber, label: 'B — 80-95%'),
                      ),
                      const SizedBox(width: 8),
                      Tooltip(
                        message:
                            'Classe C: itens que representam os últimos 5% do faturamento. Costumam ser a maioria do catálogo, mas vendem pouco — candidatos a promoção ou corte.',
                        child:
                            _LegendaChip(cor: Colors.red, label: 'C — >95%'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Total: ${state.dados!.meta.totalItems} produtos '
                    '(${state.dados!.items.length} nesta página)',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  ...state.dados!.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _CurvaAbcCard(item: item),
                    ),
                  ),
                  // Paginação
                  if (state.totalPages > 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.chevron_left),
                            label: const Text('Anterior'),
                            onPressed: state.page > 1
                                ? () => _aplicar(page: state.page - 1)
                                : null,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '${state.page}/${state.totalPages}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
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
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LegendaChip extends StatelessWidget {
  final Color cor;
  final String label;
  const _LegendaChip({required this.cor, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      );
}

class _CurvaAbcCard extends StatelessWidget {
  final dynamic item;
  const _CurvaAbcCard({required this.item});

  Color get _cor => item.classeAbc == 'A'
      ? Colors.green
      : item.classeAbc == 'B'
          ? Colors.amber
          : Colors.red;

  @override
  Widget build(BuildContext context) {
    final cor = _cor;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: cor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item.referenciaNome ??
                                    item.categoriaNome ??
                                    'Sem categoria',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13),
                              ),
                              if (item.corNome != null ||
                                  item.tamanhoNome != null)
                                Text(
                                  [item.corNome, item.tamanhoNome]
                                      .whereType<String>()
                                      .join(' · '),
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.black54),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _fmtMoeda(item.valorTotalVendido as double),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                            Tooltip(
                              message:
                                  'Participação: quanto este item sozinho representa do faturamento total do período filtrado.',
                              child: Text(
                                '${item.quantidadeVendida} un. · '
                                '${(item.percentualParticipacao as double).toStringAsFixed(1)}%',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Tooltip(
                          message: item.classeAbc == 'A'
                              ? 'Classe A: item entre os que somam 80% do faturamento — mais importante, evite ruptura.'
                              : item.classeAbc == 'B'
                                  ? 'Classe B: item na faixa de 80% a 95% do faturamento acumulado — relevante, atenção intermediária.'
                                  : 'Classe C: item nos últimos 5% do faturamento — vende pouco, candidato a promoção ou corte.',
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: cor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.classeAbc as String,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: cor,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _BarraAcumulada(
                      percentual: item.percentualAcumulado as double,
                      cor: cor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarraAcumulada extends StatelessWidget {
  final double percentual;
  final Color cor;
  const _BarraAcumulada({required this.percentual, required this.cor});

  @override
  Widget build(BuildContext context) {
    final fracao = (percentual / 100).clamp(0.0, 1.0);
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fracao,
              minHeight: 5,
              backgroundColor: Colors.black.withValues(alpha: 0.06),
              valueColor: AlwaysStoppedAnimation(cor),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Tooltip(
          message:
              'Acumulado: soma das participações de todos os itens até este, na lista ordenada do maior para o menor faturamento. É esse número que decide a classe (A/B/C).',
          child: Text(
            '${percentual.toStringAsFixed(1)}% acum.',
            style: const TextStyle(fontSize: 10, color: Colors.black45),
          ),
        ),
      ],
    );
  }
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
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Text('$label: ',
                  style: const TextStyle(
                      fontSize: 12, color: Colors.black54)),
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

class _EstadoCard extends StatelessWidget {
  final String titulo;
  final String descricao;
  final bool loading;
  final VoidCallback? onRetry;

  const _EstadoCard({
    required this.titulo,
    required this.descricao,
    this.loading = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) => Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (loading)
                const CircularProgressIndicator.adaptive()
              else
                const Icon(Icons.bar_chart, size: 40),
              const SizedBox(height: 12),
              Text(titulo,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(descricao,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium),
              if (onRetry != null) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar novamente'),
                  onPressed: onRetry,
                ),
              ],
            ],
          ),
        ),
      );
}

class _ResumoAbcCard extends StatelessWidget {
  final int totalItems;
  final List<dynamic> itens;
  const _ResumoAbcCard({required this.totalItems, required this.itens});

  @override
  Widget build(BuildContext context) {
    final valorTotal = itens.fold<double>(
        0, (soma, item) => soma + (item.valorTotalVendido as double));
    final qtdA = itens.where((i) => i.classeAbc == 'A').length;
    final qtdB = itens.where((i) => i.classeAbc == 'B').length;
    final qtdC = itens.where((i) => i.classeAbc == 'C').length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumo (nesta página)',
            style: TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Kpi(label: 'Produtos (total)', valor: '$totalItems'),
              _Kpi(label: 'Valor vendido', valor: _fmtMoeda(valorTotal)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _Kpi(label: 'Classe A', valor: '$qtdA'),
              _Kpi(label: 'Classe B', valor: '$qtdB'),
              _Kpi(label: 'Classe C', valor: '$qtdC'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  final String label;
  final String valor;
  const _Kpi({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 10, color: Colors.white70)),
            Text(valor,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ],
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
                cor: Colors.green,
                titulo: 'Classe A',
                texto:
                    'Poucos itens, mas respondem por 80% do faturamento. São os campeões de venda — nunca deixe faltar em estoque.',
              ),
              _ComoFuncionaItem(
                cor: Colors.amber,
                titulo: 'Classe B',
                texto:
                    'Itens que somam mais 15% do faturamento (de 80% a 95% acumulado). Bons, mas não são prioridade máxima.',
              ),
              _ComoFuncionaItem(
                cor: Colors.red,
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
                style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
          ],
        ),
      );
}

class _CurvaAbcVisual extends StatelessWidget {
  final List<dynamic> itens;
  const _CurvaAbcVisual({required this.itens});

  @override
  Widget build(BuildContext context) {
    final total = itens.length;
    final qtdA = itens.where((i) => i.classeAbc == 'A').length;
    final qtdB = itens.where((i) => i.classeAbc == 'B').length;
    final qtdC = total - qtdA - qtdB;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Distribuição da curva ABC',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (total == 0)
              const Text('Sem dados para exibir.',
                  style: TextStyle(color: Colors.black54, fontSize: 12))
            else ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 18,
                  child: Row(
                    children: [
                      if (qtdA > 0)
                        Expanded(
                          flex: qtdA,
                          child: Container(color: Colors.green),
                        ),
                      if (qtdB > 0)
                        Expanded(
                          flex: qtdB,
                          child: Container(color: Colors.amber),
                        ),
                      if (qtdC > 0)
                        Expanded(
                          flex: qtdC,
                          child: Container(color: Colors.red),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _LegendaChip(
                      cor: Colors.green,
                      label:
                          'A: $qtdA (${(qtdA * 100 / total).toStringAsFixed(0)}%)'),
                  _LegendaChip(
                      cor: Colors.amber,
                      label:
                          'B: $qtdB (${(qtdB * 100 / total).toStringAsFixed(0)}%)'),
                  _LegendaChip(
                      cor: Colors.red,
                      label:
                          'C: $qtdC (${(qtdC * 100 / total).toStringAsFixed(0)}%)'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
