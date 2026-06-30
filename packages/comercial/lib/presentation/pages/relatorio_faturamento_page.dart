import 'package:comercial/presentation/blocs/relatorio_faturamento_bloc/relatorio_faturamento_bloc.dart';
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
  bool _exportandoPdf = false;

  @override
  void initState() {
    super.initState();
    final (ini, fim) = _mesAtual();
    _dataInicial = ini;
    _dataFinal = fim;
    _bloc = sl<RelatorioFaturamentoBloc>()
      ..add(RelatorioFaturamentoCarregar(
          dataInicial: ini, dataFinal: fim));
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
    final fmt =
        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    setState(() {
      if (isInicial) {
        _dataInicial = fmt;
      } else {
        _dataFinal = fmt;
      }
    });
  }

  void _aplicarFiltro() {
    _bloc.add(RelatorioFaturamentoCarregar(
        dataInicial: _dataInicial, dataFinal: _dataFinal));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RelatorioFaturamentoBloc>.value(
      value: _bloc,
      child: BlocBuilder<RelatorioFaturamentoBloc, RelatorioFaturamentoState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Faturamento e Ticket Médio'),
              actions: [
                if (state.step == RelatorioFaturamentoStep.sucesso &&
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
                            await RelatorioPdfExporter.exportarFaturamento(
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
                _FiltroCard(
                  dataInicial: _dataInicial,
                  dataFinal: _dataFinal,
                  onSelecionarInicial: () => _selecionarData(true),
                  onSelecionarFinal: () => _selecionarData(false),
                  onAplicar: _aplicarFiltro,
                  onPeriodoRapido: (ini, fim) {
                    setState(() {
                      _dataInicial = ini;
                      _dataFinal = fim;
                    });
                    _bloc.add(RelatorioFaturamentoCarregar(
                        dataInicial: ini, dataFinal: fim));
                  },
                ),
                const SizedBox(height: 16),
                if (state.step == RelatorioFaturamentoStep.carregando)
                  const _EstadoCard(
                    icon: Icons.hourglass_top,
                    titulo: 'Carregando relatório',
                    descricao: 'Consultando dados de faturamento...',
                    loading: true,
                  )
                else if (state.step == RelatorioFaturamentoStep.falha)
                  _EstadoCard(
                    icon: Icons.error_outline,
                    titulo: 'Falha ao carregar',
                    descricao: state.erro ?? 'Erro desconhecido',
                    onRetry: _aplicarFiltro,
                  )
                else if (state.step == RelatorioFaturamentoStep.inicial)
                  const _EstadoCard(
                    icon: Icons.bar_chart_outlined,
                    titulo: 'Aplique o filtro',
                    descricao: 'Selecione o período e toque em Consultar.',
                  )
                else if (state.dados != null) ...[
                  _HeaderKpi(relatorio: state.dados!),
                  const SizedBox(height: 16),
                  ...state.dados!.empresas.map((emp) =>
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _EmpresaCard(empresa: emp),
                      )),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FiltroCard extends StatelessWidget {
  final String dataInicial;
  final String dataFinal;
  final VoidCallback onSelecionarInicial;
  final VoidCallback onSelecionarFinal;
  final VoidCallback onAplicar;
  final void Function(String ini, String fim) onPeriodoRapido;

  const _FiltroCard({
    required this.dataInicial,
    required this.dataFinal,
    required this.onSelecionarInicial,
    required this.onSelecionarFinal,
    required this.onAplicar,
    required this.onPeriodoRapido,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtros',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _chipPeriodo(context, 'Este mês', () {
                    final now = DateTime.now();
                    final ultimo = DateTime(now.year, now.month + 1, 0).day;
                    final m = now.month.toString().padLeft(2, '0');
                    onPeriodoRapido(
                      '${now.year}-$m-01',
                      '${now.year}-$m-${ultimo.toString().padLeft(2, '0')}',
                    );
                  }),
                  const SizedBox(width: 8),
                  _chipPeriodo(context, '7 dias', () {
                    final fim = DateTime.now();
                    final ini = fim.subtract(const Duration(days: 6));
                    onPeriodoRapido(_isoDate(ini), _isoDate(fim));
                  }),
                  const SizedBox(width: 8),
                  _chipPeriodo(context, '30 dias', () {
                    final fim = DateTime.now();
                    final ini = fim.subtract(const Duration(days: 29));
                    onPeriodoRapido(_isoDate(ini), _isoDate(fim));
                  }),
                  const SizedBox(width: 8),
                  _chipPeriodo(context, '90 dias', () {
                    final fim = DateTime.now();
                    final ini = fim.subtract(const Duration(days: 89));
                    onPeriodoRapido(_isoDate(ini), _isoDate(fim));
                  }),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _DateButton(
                    label: 'De',
                    date: _fmtData(dataInicial),
                    onTap: onSelecionarInicial,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _DateButton(
                    label: 'Até',
                    date: _fmtData(dataFinal),
                    onTap: onSelecionarFinal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onAplicar,
                icon: const Icon(Icons.search),
                label: const Text('Consultar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chipPeriodo(
      BuildContext ctx, String label, VoidCallback onTap) =>
      ActionChip(
        label: Text(label),
        visualDensity: VisualDensity.compact,
        onPressed: onTap,
      );

  String _isoDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class _DateButton extends StatelessWidget {
  final String label;
  final String date;
  final VoidCallback onTap;

  const _DateButton(
      {required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
}

class _HeaderKpi extends StatelessWidget {
  final dynamic relatorio;
  const _HeaderKpi({required this.relatorio});

  @override
  Widget build(BuildContext context) {
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
            'Resumo do período',
            style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Kpi(
                  label: 'Faturamento',
                  valor: _fmtMoeda(relatorio.total as double)),
              _Kpi(
                  label: 'Ticket médio',
                  valor: _fmtMoeda(relatorio.ticketMedio as double)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _Kpi(
                  label: 'Vendas',
                  valor: '${relatorio.quantidadeVendas}'),
              _Kpi(
                  label: 'Produtos vendidos',
                  valor: '${relatorio.quantidadeProdutosVendidos}'),
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
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white70)),
          Text(valor,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ],
      ),
    );
  }
}

class _EmpresaCard extends StatelessWidget {
  final dynamic empresa;
  const _EmpresaCard({required this.empresa});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 5,
              decoration: const BoxDecoration(
                color: Color(0xFF2E7D32),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                title: Text(
                  empresa.empresaNome as String,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14),
                ),
                subtitle: Text(
                  '${_fmtMoeda(empresa.total as double)} · Ticket: ${_fmtMoeda(empresa.ticketMedio as double)}',
                  style: const TextStyle(fontSize: 12),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if ((empresa.vendedores as List).isNotEmpty) ...[
                          const _SectionLabel('Vendedores'),
                          for (final v in empresa.vendedores as List)
                            _VendedorRow(v: v),
                        ],
                        if ((empresa.produtos as List).isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const _SectionLabel('Top produtos'),
                          for (final p
                              in (empresa.produtos as List).take(5))
                            _ProdutoRow(p: p),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(label,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.black54)),
      );
}

class _VendedorRow extends StatelessWidget {
  final dynamic v;
  const _VendedorRow({required this.v});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Expanded(
                child: Text(v.funcionarioNome as String,
                    style: const TextStyle(fontSize: 12))),
            Text(_fmtMoeda(v.total as double),
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Text('${v.quantidadeVendas} vnd.',
                style: const TextStyle(fontSize: 11, color: Colors.black54)),
          ],
        ),
      );
}

class _ProdutoRow extends StatelessWidget {
  final dynamic p;
  const _ProdutoRow({required this.p});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${p.referenciaNome} ${p.corNome} ${p.tamanhoNome}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
            Text(_fmtMoeda(p.total as double),
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Text('${p.quantidadeProdutosVendidos} un.',
                style: const TextStyle(fontSize: 11, color: Colors.black54)),
          ],
        ),
      );
}

class _EstadoCard extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String descricao;
  final bool loading;
  final VoidCallback? onRetry;

  const _EstadoCard({
    required this.icon,
    required this.titulo,
    required this.descricao,
    this.loading = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (loading)
              const CircularProgressIndicator.adaptive()
            else
              Icon(icon, size: 40),
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
}
