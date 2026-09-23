import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/sessao.dart';
import 'package:core/tema/siv_theme.dart';
import 'package:financeiro/presentation.dart';
import 'package:financeiro/presentation/utils/nomes_dos_meses.dart';
import 'package:financeiro/presentation/widgets/cadastros_de_despesas_body.dart';
import 'package:financeiro/presentation/widgets/calendario_de_despesas_body.dart';
import 'package:financeiro/presentation/widgets/painel_de_despesas.dart';
import 'package:flutter/material.dart';

const _corBorda = Color(0x2E26282A);
const _corIconeFraco = Color(0x8026282A);
const _corTabInativa = Color(0x7326282A);
const _corTextoForte = Color(0xFF26282A);
const _corAzulMedio = Color(0xFF5980A6);

class ControleDeDespesasPage extends StatefulWidget {
  const ControleDeDespesasPage({super.key});

  @override
  State<ControleDeDespesasPage> createState() => _ControleDeDespesasPageState();
}

class _ControleDeDespesasPageState extends State<ControleDeDespesasPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final DashboardDeDespesasBloc _dashboardBloc;
  late final CalendarioDeDespesasBloc _calendarioBloc;
  late int _ano;
  late int _mes;

  int get _empresaId => sl<IAcessoGlobalSessao>().empresaIdDaSessao ?? 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final agora = DateTime.now();
    _ano = agora.year;
    _mes = agora.month;
    _dashboardBloc = sl<DashboardDeDespesasBloc>()
      ..add(DashboardDeDespesasIniciou(
          empresaId: _empresaId, ano: _ano, mes: _mes));
    _calendarioBloc = sl<CalendarioDeDespesasBloc>()
      ..add(CalendarioDeDespesasIniciou(empresaId: _empresaId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _mudarMes(int delta) {
    var novoMes = _mes + delta;
    var novoAno = _ano;
    if (novoMes > 12) {
      novoMes = 1;
      novoAno++;
    } else if (novoMes < 1) {
      novoMes = 12;
      novoAno--;
    }
    setState(() {
      _ano = novoAno;
      _mes = novoMes;
    });
    _recarregar();
  }

  void _recarregar() {
    _dashboardBloc.add(
      DashboardDeDespesasIniciou(empresaId: _empresaId, ano: _ano, mes: _mes),
    );
    _calendarioBloc.add(CalendarioDeDespesasMesAlterado(ano: _ano, mes: _mes));
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;

    return MultiBlocProvider(
      providers: [
        BlocProvider<DashboardDeDespesasBloc>.value(value: _dashboardBloc),
        BlocProvider<CalendarioDeDespesasBloc>.value(value: _calendarioBloc),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          final estreito = constraints.maxWidth < 1000;
          final seletorMes = _SeletorMes(
            label: '${nomesDosMeses[_mes - 1].toUpperCase()} $_ano',
            onAnterior: () => _mudarMes(-1),
            onProximo: () => _mudarMes(1),
          );

          return Scaffold(
            floatingActionButton: estreito
                ? FloatingActionButton.extended(
                    onPressed: () async {
                      final result = await abrirLancarDespesa(context);
                      if (result == true) {
                        _recarregar();
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('LANÇAR'),
                  )
                : null,
            body: Column(
              children: [
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Financeiro / ',
                              style: TextStyle(
                                  fontSize: 14, color: _corIconeFraco),
                            ),
                            Text(
                              'Controle de despesas',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: _corTextoForte,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              // No estreito o seletor de mês desce pro topo
                              // do TabBarView -- aqui, colado ao "LANÇAR
                              // DESPESA" e à breadcrumb, ele estoura a linha.
                              if (!estreito) seletorMes,
                              // No estreito o FAB assume o "lançar despesa"
                              // -- manter os dois aqui duplicaria a ação.
                              if (!estreito)
                                FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  onPressed: () async {
                                    final result =
                                        await abrirLancarDespesa(context);
                                    if (result == true) {
                                      _recarregar();
                                    }
                                  },
                                  icon: const Padding(
                                    padding: EdgeInsetsGeometry.only(
                                        top: 16, bottom: 16),
                                    child: Icon(Icons.add, size: 16),
                                  ),
                                  label: const Text('LANÇAR DESPESA'),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ColoredBox(
                    color: Colors.white,
                    child: Divider(height: 1, color: cores.hairline)),
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorColor: _corAzulMedio,
                    indicatorWeight: 2,
                    labelColor: _corTextoForte,
                    unselectedLabelColor: _corTabInativa,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                    labelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    tabs: const [
                      Tab(text: 'PAINEL'),
                      Tab(text: 'CALENDÁRIO'),
                      Tab(text: 'CADASTROS'),
                    ],
                  ),
                ),
                if (estreito)
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: seletorMes,
                  ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      PainelDeDespesas(
                          onVerCalendario: () => _tabController.animateTo(1)),
                      CalendarioDeDespesasBody(
                          onAlterou: () => _dashboardBloc.add(
                                DashboardDeDespesasIniciou(
                                    empresaId: _empresaId,
                                    ano: _ano,
                                    mes: _mes),
                              )),
                      const CadastrosDeDespesasBody(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SeletorMes extends StatelessWidget {
  final String label;
  final VoidCallback onAnterior;
  final VoidCallback onProximo;

  const _SeletorMes({
    required this.label,
    required this.onAnterior,
    required this.onProximo,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _corBorda),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BotaoSeta(icon: Icons.chevron_left, onPressed: onAnterior),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: _corTextoForte,
              ),
            ),
          ),
          _BotaoSeta(icon: Icons.chevron_right, onPressed: onProximo),
        ],
      ),
    );
  }
}

class _BotaoSeta extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _BotaoSeta({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 18, color: _corIconeFraco),
      ),
    );
  }
}
