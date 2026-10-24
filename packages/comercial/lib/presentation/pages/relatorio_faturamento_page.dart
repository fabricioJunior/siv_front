import 'dart:math' as math;

import 'package:comercial/domain/models/relatorios.dart';
import 'package:comercial/presentation/blocs/relatorio_faturamento_bloc/relatorio_faturamento_bloc.dart';
import 'package:comercial/presentation/relatorios/pdf/relatorio_pdf_exporter.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

const double _larguraPontoGrafico = 48;

String _fmtMoeda(double v) {
  final p = v.toStringAsFixed(2).split('.');
  final inteiro = p[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]}.',
  );
  return 'R\$ $inteiro,${p[1]}';
}

String _fmtData(String iso) {
  final p = iso.split('-');
  return p.length == 3 ? '${p[2]}/${p[1]}/${p[0]}' : iso;
}

String _isoDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

const _rotulosAgrupar = {'dia': 'Dia', 'semana': 'Semana', 'mes': 'Mês'};

String _fmtPeriodo(String periodo, String agruparPor) {
  final p = periodo.split('-');
  if (agruparPor == 'mes' && p.length == 2) {
    const meses = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
    ];
    final i = int.tryParse(p[1]);
    if (i == null || i < 1 || i > 12) return periodo;
    return '${meses[i - 1]}/${p[0].substring(2)}';
  }
  if (p.length == 3) return '${p[2]}/${p[1]}';
  return periodo;
}

/// Variação % (atual vs anterior). `null` = sem base de comparação.
double? _variacao(num atual, num anterior) =>
    anterior == 0 ? null : (atual - anterior) / anterior * 100;

double _pecasPorVenda(int pecas, int vendas) => vendas == 0 ? 0 : pecas / vendas;

class RelatorioFaturamentoPage extends StatefulWidget {
  const RelatorioFaturamentoPage({super.key});

  @override
  State<RelatorioFaturamentoPage> createState() =>
      _RelatorioFaturamentoPageState();
}

class _RelatorioFaturamentoPageState extends State<RelatorioFaturamentoPage> {
  late final RelatorioFaturamentoBloc _bloc;
  late String _dataInicial;
  late String _dataFinal;
  String _agruparPor = 'dia';
  bool _exportandoPdf = false;

  @override
  void initState() {
    super.initState();
    final hoje = DateTime.now();
    _dataInicial = _isoDate(DateTime(hoje.year, hoje.month, 1));
    _dataFinal = _isoDate(hoje);
    _bloc = sl<RelatorioFaturamentoBloc>();
    _aplicarFiltro();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _aplicarFiltro() {
    _bloc
      ..add(RelatorioFaturamentoCarregar(
          dataInicial: _dataInicial, dataFinal: _dataFinal))
      ..add(RelatorioFaturamentoComparativoCarregar(
        dataInicial: _dataInicial,
        dataFinal: _dataFinal,
        agruparPor: _agruparPor,
      ));
  }

  void _onAgruparPorAlterado(String valor) {
    setState(() => _agruparPor = valor);
    _bloc.add(RelatorioFaturamentoComparativoCarregar(
      dataInicial: _dataInicial,
      dataFinal: _dataFinal,
      agruparPor: valor,
    ));
  }

  Future<void> _abrirFiltroPeriodo() async {
    final r = await abrirFiltroPeriodoSheet(
      context: context,
      dataInicioAtual: DateTime.tryParse(_dataInicial) ?? DateTime.now(),
      dataFimAtual: DateTime.tryParse(_dataFinal) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      permitirHora: false,
    );
    if (r == null || !mounted) return;
    setState(() {
      _dataInicial = _isoDate(r.dataInicio);
      _dataFinal = _isoDate(r.dataFim);
    });
    _aplicarFiltro();
  }

  Future<void> _exportar(RelatorioFaturamentoState state) async {
    setState(() => _exportandoPdf = true);
    await RelatorioPdfExporter.exportarFaturamento(
      state.dados!,
      state.dataInicial,
      state.dataFinal,
    );
    if (mounted) setState(() => _exportandoPdf = false);
  }

  List<Widget> _kpis(RelatorioFaturamento d, RelatorioFaturamento? a) {
    final pecas = _pecasPorVenda(d.quantidadeProdutosVendidos, d.quantidadeVendas);
    return [
      _Kpi(
        rotulo: 'Faturamento',
        valor: _fmtMoeda(d.total),
        variacao: a == null ? null : _variacao(d.total, a.total),
        destaque: true,
      ),
      _Kpi(
        rotulo: 'Ticket médio',
        valor: _fmtMoeda(d.ticketMedio),
        variacao: a == null ? null : _variacao(d.ticketMedio, a.ticketMedio),
      ),
      _Kpi(
        rotulo: 'Vendas',
        valor: '${d.quantidadeVendas}',
        variacao:
            a == null ? null : _variacao(d.quantidadeVendas, a.quantidadeVendas),
      ),
      _Kpi(
        rotulo: 'Peças por venda',
        valor: pecas.toStringAsFixed(1).replaceAll('.', ','),
        variacao: a == null
            ? null
            : _variacao(
                pecas,
                _pecasPorVenda(
                    a.quantidadeProdutosVendidos, a.quantidadeVendas)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RelatorioFaturamentoBloc>.value(
      value: _bloc,
      child: BlocBuilder<RelatorioFaturamentoBloc, RelatorioFaturamentoState>(
        builder: (context, state) {
          final d = state.dados;
          final pronto = state.step == RelatorioFaturamentoStep.sucesso && d != null;
          return Scaffold(
            body: SafeArea(
              child: RelatorioScaffold(
                titulo: 'Faturamento e Ticket',
                carregando: !pronto &&
                    state.step != RelatorioFaturamentoStep.falha,
                erro: state.step == RelatorioFaturamentoStep.falha
                    ? (state.erro ?? 'Falha ao carregar relatório de faturamento.')
                    : null,
                onTentarDeNovo: _aplicarFiltro,
                vazio: pronto && d.quantidadeVendas == 0 && d.empresas.isEmpty,
                filtros: [
                  RelatorioFiltroChip(
                    rotulo: 'Período',
                    valor: '${_fmtData(_dataInicial)} - ${_fmtData(_dataFinal)}',
                    onTap: _abrirFiltroPeriodo,
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Agrupar por',
                    onSelected: _onAgruparPorAlterado,
                    itemBuilder: (_) => [
                      for (final e in _rotulosAgrupar.entries)
                        PopupMenuItem(value: e.key, child: Text(e.value)),
                    ],
                    child: IgnorePointer(
                      child: RelatorioFiltroChip(
                        rotulo: 'Agrupar por',
                        valor: _rotulosAgrupar[_agruparPor],
                        onTap: () {},
                      ),
                    ),
                  ),
                ],
                acoes: [
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
                kpis: pronto ? _kpis(d, state.anteriorDados) : const [],
                corpo: pronto
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _GraficoCard(
                            step: state.comparativoStep,
                            atual: state.comparativoDados,
                            anoAnterior: state.anoAnteriorDados,
                            agruparPor: _agruparPor,
                          ),
                          const SizedBox(height: 16),
                          _Quebra(empresas: d.empresas),
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

/// KPI; variação < 0,5% vira "estável" (sem seta).
class _Kpi extends StatelessWidget {
  final String rotulo;
  final String valor;
  final double? variacao;
  final bool destaque;

  const _Kpi({
    required this.rotulo,
    required this.valor,
    required this.variacao,
    this.destaque = false,
  });

  @override
  Widget build(BuildContext context) {
    final estavel = variacao != null && variacao!.abs() < 0.5;
    final card = RelatorioKpiCard(
      rotulo: rotulo,
      valor: valor,
      variacao: estavel ? null : variacao,
      destaque: destaque,
    );
    if (!estavel) return card;
    final mobile = relatorioMobile(context);
    return Stack(
      children: [
        card,
        Positioned(
          left: mobile ? 14 : 18,
          bottom: mobile ? 3 : 5,
          child: Text(
            'estável',
            style: context.sivTextos.apoio.copyWith(
              fontSize: mobile ? 11 : 12,
              color: context.sivColors.textoApoio,
            ),
          ),
        ),
      ],
    );
  }
}

class _GraficoCard extends StatelessWidget {
  final RelatorioFaturamentoComparativoStep step;
  final RelatorioFaturamentoComparativo? atual;
  final RelatorioFaturamentoComparativo? anoAnterior;
  final String agruparPor;

  const _GraficoCard({
    required this.step,
    required this.atual,
    required this.anoAnterior,
    required this.agruparPor,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final mobile = relatorioMobile(context);
    final unidade = switch (agruparPor) {
      'mes' => 'MÊS',
      'semana' => 'SEMANA',
      _ => 'DIA',
    };
    final pontos = atual?.pontos ?? const <RelatorioFaturamentoComparativoPonto>[];
    final Widget conteudo;
    if (step == RelatorioFaturamentoComparativoStep.carregando ||
        step == RelatorioFaturamentoComparativoStep.ocioso) {
      conteudo = const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
    } else if (step == RelatorioFaturamentoComparativoStep.falha) {
      conteudo = const SizedBox(
        height: 80,
        child: Center(child: Text('Falha ao carregar o gráfico.')),
      );
    } else if (pontos.isEmpty) {
      conteudo = const SizedBox(
        height: 80,
        child: Center(child: Text('Sem dados para o período.')),
      );
    } else {
      conteudo = LayoutBuilder(
        builder: (_, c) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: math.max(c.maxWidth, pontos.length * _larguraPontoGrafico),
            child: _Linhas(
              pontos: pontos,
              anoAnterior: {
                for (final p in anoAnterior?.pontos ?? const []) p.periodo: p.faturamento,
              },
              agruparPor: agruparPor,
              mobile: mobile,
            ),
          ),
        ),
      );
    }
    return Container(
      padding: EdgeInsets.all(mobile ? 14 : 18),
      decoration: BoxDecoration(
        color: cores.superficie,
        border: Border.all(color: cores.hairline),
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FATURAMENTO POR $unidade',
            style: textos.apoio.copyWith(
              fontSize: 10.5,
              letterSpacing: 1.47,
              color: cores.acoAtivo,
            ),
          ),
          const SizedBox(height: 12),
          conteudo,
        ],
      ),
    );
  }
}

class _Linhas extends StatelessWidget {
  final List<RelatorioFaturamentoComparativoPonto> pontos;
  final Map<String, double> anoAnterior;
  final String agruparPor;
  final bool mobile;

  const _Linhas({
    required this.pontos,
    required this.anoAnterior,
    required this.agruparPor,
    required this.mobile,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final apoio = context.sivTextos.apoio;
    final atualSpots = [
      for (var i = 0; i < pontos.length; i++)
        FlSpot(i.toDouble(), pontos[i].faturamento),
    ];
    final anteriorSpots = [
      for (var i = 0; i < pontos.length; i++)
        FlSpot(i.toDouble(), anoAnterior[pontos[i].periodo] ?? 0),
    ];
    final maxY = [...atualSpots, ...anteriorSpots]
        .fold<double>(0, (a, s) => s.y > a ? s.y : a);
    final acumAtual = _acumulado(atualSpots);
    final acumAnterior = _acumulado(anteriorSpots);
    return SizedBox(
      height: mobile ? 160 : 240,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY == 0 ? 1 : maxY * 1.15,
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: cores.hairline, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 26,
                interval: 1,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= pontos.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _fmtPeriodo(pontos[i].periodo, agruparPor),
                      style: apoio.copyWith(
                          fontSize: 10, color: cores.textoApoio),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => cores.superficie,
              getTooltipItems: (spots) => [
                for (final s in spots)
                  LineTooltipItem(
                    '${s.barIndex == 0 ? 'Atual' : 'Ano ant.'}: ${_fmtMoeda(s.y)}\n'
                    'Acumulado: ${_fmtMoeda((s.barIndex == 0 ? acumAtual : acumAnterior)[s.spotIndex])}',
                    apoio.copyWith(color: cores.tinta),
                  ),
              ],
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: atualSpots,
              color: cores.aco,
              barWidth: 2.5,
              isCurved: false,
              dotData: FlDotData(show: !mobile),
            ),
            LineChartBarData(
              spots: anteriorSpots,
              color: cores.aco.withValues(alpha: 0.45),
              barWidth: 2,
              dashArray: [5, 4],
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}

List<double> _acumulado(List<FlSpot> spots) {
  var soma = 0.0;
  return [for (final s in spots) soma += s.y];
}

class _Quebra extends StatelessWidget {
  final List<RelatorioFaturamentoEmpresa> empresas;
  const _Quebra({required this.empresas});

  @override
  Widget build(BuildContext context) {
    final linhas = <_Linha>[
      for (final e in empresas) ...[
        _Linha(e.empresaNome, e.total, e.quantidadeVendas, e.ticketMedio,
            empresa: true),
        for (final v in e.vendedores)
          _Linha(v.funcionarioNome.toUpperCase(), v.total, v.quantidadeVendas,
              v.ticketMedio),
      ],
    ];
    if (linhas.isEmpty) return const SizedBox.shrink();
    final textos = context.sivTextos;
    final cores = context.sivColors;
    Widget txt(String s, {bool forte = false}) => Text(
          s,
          style: forte
              ? textos.corpo.copyWith(fontWeight: FontWeight.w600)
              : textos.corpo.copyWith(color: cores.tinta),
        );
    return RelatorioTabela<_Linha>(
      colunas: const [
        RelatorioColuna(id: 'nome', titulo: 'Loja / Vendedor', ordenavel: false, flex: 3),
        RelatorioColuna(id: 'total', titulo: 'Faturamento', numerica: true, ordenavel: false),
        RelatorioColuna(id: 'vendas', titulo: 'Vendas', numerica: true, ordenavel: false),
        RelatorioColuna(id: 'ticket', titulo: 'Ticket médio', numerica: true, ordenavel: false),
      ],
      itens: linhas,
      celulas: (_, l) => [
        Padding(
          padding: EdgeInsets.only(left: l.empresa ? 0 : 16),
          child: txt(l.nome, forte: l.empresa),
        ),
        txt(_fmtMoeda(l.total), forte: l.empresa),
        txt('${l.vendas}', forte: l.empresa),
        txt(_fmtMoeda(l.ticket), forte: l.empresa),
      ],
      itemMobile: (_, l) => RelatorioItemMobile(
        titulo: l.nome,
        apoio: ['${l.vendas} vendas', 'ticket ${_fmtMoeda(l.ticket)}'],
        valor: _fmtMoeda(l.total),
      ),
    );
  }
}

class _Linha {
  final String nome;
  final double total;
  final int vendas;
  final double ticket;
  final bool empresa;
  _Linha(this.nome, this.total, this.vendas, this.ticket, {this.empresa = false});
}
