import 'package:comercial/domain/use_cases/get_relatorio_frequencia_clientes.dart';
import 'package:comercial/presentation/blocs/relatorio_frequencia_clientes_bloc/relatorio_frequencia_clientes_bloc.dart';
import 'package:comercial/presentation/widgets/frequencia/frequencia_criterios.dart';
import 'package:comercial/presentation/widgets/frequencia/frequencia_curva_abc.dart';
import 'package:comercial/presentation/widgets/frequencia/frequencia_distribuicao.dart';
import 'package:comercial/presentation/widgets/frequencia/frequencia_formato.dart';
import 'package:comercial/presentation/widgets/frequencia/frequencia_painel.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

const _periodos = <(FrequenciaPeriodo, String)>[
  (FrequenciaPeriodo.dias90, '90 dias'),
  (FrequenciaPeriodo.meses6, '6 meses'),
  (FrequenciaPeriodo.meses12, '12 meses'),
  (FrequenciaPeriodo.personalizado, 'Personalizado'),
];

class RelatorioFrequenciaClientesPage extends StatefulWidget {
  const RelatorioFrequenciaClientesPage({super.key});

  @override
  State<RelatorioFrequenciaClientesPage> createState() =>
      _RelatorioFrequenciaClientesPageState();
}

class _RelatorioFrequenciaClientesPageState
    extends State<RelatorioFrequenciaClientesPage> {
  late final RelatorioFrequenciaClientesBloc _bloc;
  bool _iniciou = false;
  bool _criterios = false;

  @override
  void initState() {
    super.initState();
    _bloc = RelatorioFrequenciaClientesBloc(sl<GetRelatorioFrequenciaClientes>());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mobile = relatorioMobile(context);
    if (!_iniciou) {
      _iniciou = true;
      _bloc.add(FrequenciaIniciou(acumulando: mobile));
    } else {
      _bloc.add(FrequenciaMudouModo(mobile));
    }
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  Future<void> _escolherPeriodo(RelatorioFrequenciaClientesState s) async {
    final r = await abrirFiltroPeriodoSheet(
      context: context,
      dataInicioAtual: s.inicio,
      dataFimAtual: s.fim,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      permitirHora: false,
    );
    if (r == null || !mounted) return;
    if (!RelatorioFrequenciaClientesBloc.periodoValido(r.dataInicio, r.dataFim)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Período máximo: 24 meses.')),
      );
      return;
    }
    _bloc.add(FrequenciaMudouPeriodo(
      FrequenciaPeriodo.personalizado,
      inicio: r.dataInicio,
      fim: r.dataFim,
    ));
  }

  void _selecionarPeriodo(
    RelatorioFrequenciaClientesState s,
    FrequenciaPeriodo p,
  ) {
    if (p == FrequenciaPeriodo.personalizado) {
      _escolherPeriodo(s);
    } else if (p != s.periodo) {
      _bloc.add(FrequenciaMudouPeriodo(p));
    }
  }

  // L: exportar CSV de todas as páginas (com o filtro atual de [s]).
  void _exportar(RelatorioFrequenciaClientesState s) {}

  // L: filtros, tabela, cartões, paginação.
  // Recebe o estado; eventos via `_bloc.add(...)`. Mobile: s.acumulando == true.
  Widget _buildLista(BuildContext context, RelatorioFrequenciaClientesState s) =>
      const SizedBox.shrink();

  bool _onScroll(ScrollNotification n) {
    if (n.depth == 0 && n.metrics.extentAfter < 300) {
      _bloc.add(const FrequenciaCarregouMais());
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RelatorioFrequenciaClientesBloc>.value(
      value: _bloc,
      child: BlocBuilder<RelatorioFrequenciaClientesBloc, RelatorioFrequenciaClientesState>(
        builder: (context, s) {
          final mobile = relatorioMobile(context);
          final erro = s.status == FrequenciaStatus.erro;
          return Scaffold(
            body: SafeArea(
              child: NotificationListener<ScrollNotification>(
                onNotification: _onScroll,
                child: RelatorioScaffold(
                  titulo: 'Frequência de clientes',
                  filtros: [
                    if (mobile)
                      for (final p in _periodos)
                        _PeriodoChip(
                          rotulo: p.$2,
                          ativo: p.$1 == s.periodo,
                          onTap: () => _selecionarPeriodo(s, p.$1),
                        )
                    else
                      _PeriodoSegmentado(
                        atual: s.periodo,
                        onTap: (p) => _selecionarPeriodo(s, p),
                      ),
                  ],
                  acoes: [
                    mobile
                        ? IconButton(
                            tooltip: 'Exportar',
                            icon: const Icon(Icons.download_outlined),
                            onPressed: () => _exportar(s),
                          )
                        : OutlinedButton.icon(
                            icon: const Icon(Icons.download_outlined, size: 16),
                            label: const Text('Exportar'),
                            onPressed: () => _exportar(s),
                          ),
                  ],
                  erro: erro ? s.erro : null,
                  onTentarDeNovo: () => _bloc.add(const FrequenciaTentouDeNovo()),
                  corpo: _corpo(context, s, mobile),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _corpo(
    BuildContext context,
    RelatorioFrequenciaClientesState s,
    bool mobile,
  ) {
    final c = context.sivColors;
    final apoio = context.sivTextos.apoio.copyWith(fontSize: 11.5, color: c.textoApoio);
    final carregando = s.status == FrequenciaStatus.inicial ||
        s.status == FrequenciaStatus.carregando;
    final vazio = s.status == FrequenciaStatus.vazio;
    final subtitulo = Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        'Compras de ${frequenciaDia(s.inicio)} a ${frequenciaDiaAno(s.fim)}',
        style: apoio,
      ),
    );
    if (carregando) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [subtitulo, const FrequenciaPainelEsqueleto()],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        subtitulo,
        FrequenciaPainel(
          state: s,
          criteriosAbertos: _criterios,
          onCriterios: () => setState(() => _criterios = !_criterios),
          onClasse: (k) => _bloc.add(FrequenciaMudouClasse(k)),
          onAtrasados: () => _bloc.add(const FrequenciaAlternouAtrasados()),
        ),
        if (!mobile && _criterios) ...[
          const SizedBox(height: 12),
          FrequenciaCriterios(resumo: s.resumo),
        ],
        if (vazio)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Text(
              'Nenhuma venda com cliente identificado neste período.',
              textAlign: TextAlign.center,
              style: context.sivTextos.corpo.copyWith(color: c.textoApoio),
            ),
          )
        else ...[
          if (!mobile) ...[
            const SizedBox(height: 20),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 16, child: FrequenciaCurvaAbc(resumo: s.resumo)),
                  const SizedBox(width: 20),
                  Expanded(flex: 10, child: FrequenciaDistribuicao(resumo: s.resumo)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          _buildLista(context, s),
        ],
      ],
    );
  }
}

class _PeriodoSegmentado extends StatelessWidget {
  final FrequenciaPeriodo atual;
  final ValueChanged<FrequenciaPeriodo> onTap;
  const _PeriodoSegmentado({required this.atual, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.sivColors;
    final t = context.sivTextos;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: c.hairline),
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final p in _periodos)
            InkWell(
              onTap: () => onTap(p.$1),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                color: p.$1 == atual ? c.acoEscuro : null,
                child: Text(
                  p.$2,
                  style: t.apoio.copyWith(
                    color: p.$1 == atual ? c.textoSobreEscuroTitulo : c.tinta,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PeriodoChip extends StatelessWidget {
  final String rotulo;
  final bool ativo;
  final VoidCallback onTap;
  const _PeriodoChip({required this.rotulo, required this.ativo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.sivColors;
    return Material(
      color: ativo ? c.selecaoFundo : c.superficie,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
        side: BorderSide(color: ativo ? c.aco : c.hairline),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: SivDimensoes.alvoToqueMinimo),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Center(
              child: Text(
                rotulo,
                style: context.sivTextos.apoio.copyWith(color: c.tinta),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
