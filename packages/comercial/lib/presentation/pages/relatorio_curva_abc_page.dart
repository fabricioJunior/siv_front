import 'package:comercial/presentation/blocs/relatorio_curva_abc_bloc/relatorio_curva_abc_bloc.dart';
import 'package:comercial/presentation/relatorios/pdf/relatorio_pdf_exporter.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
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
  bool _exportandoPdf = false;

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
    _bloc.add(RelatorioCurvaAbcCarregar(
        dataInicial: _dataInicial, dataFinal: _dataFinal, page: page));
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
                                  _bloc.add(RelatorioCurvaAbcCarregar(
                                      dataInicial: ini, dataFinal: fim));
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
                                  _bloc.add(RelatorioCurvaAbcCarregar(
                                      dataInicial: _dataInicial,
                                      dataFinal: _dataFinal));
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
                                  _bloc.add(RelatorioCurvaAbcCarregar(
                                      dataInicial: _dataInicial,
                                      dataFinal: _dataFinal));
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
                  // Legenda ABC
                  Row(
                    children: [
                      _LegendaChip(cor: Colors.green, label: 'A — até 80%'),
                      const SizedBox(width: 8),
                      _LegendaChip(cor: Colors.amber, label: 'B — 80-95%'),
                      const SizedBox(width: 8),
                      _LegendaChip(cor: Colors.red, label: 'C — >95%'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Total: ${state.dados!.meta.totalItems} produtos',
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
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item.referenciaNome as String,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          Text(
                            '${item.corNome} · ${item.tamanhoNome}',
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
                        Text(
                          '${item.quantidadeVendida} un. · '
                          '${(item.percentualParticipacao as double).toStringAsFixed(1)}%',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.black54),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Container(
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
