import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/sessao.dart';
import 'package:financeiro/presentation.dart';
import 'package:financeiro/presentation/utils/nomes_dos_meses.dart';
import 'package:financeiro/presentation/widgets/cadastros_de_despesas_body.dart';
import 'package:financeiro/presentation/widgets/calendario_de_despesas_body.dart';
import 'package:financeiro/presentation/widgets/painel_de_despesas.dart';
import 'package:flutter/material.dart';

class ControleDeDespesasPage extends StatefulWidget {
  const ControleDeDespesasPage({super.key});

  @override
  State<ControleDeDespesasPage> createState() =>
      _ControleDeDespesasPageState();
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
      ..add(DashboardDeDespesasIniciou(empresaId: _empresaId, ano: _ano, mes: _mes));
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
    return MultiBlocProvider(
      providers: [
        BlocProvider<DashboardDeDespesasBloc>.value(value: _dashboardBloc),
        BlocProvider<CalendarioDeDespesasBloc>.value(value: _calendarioBloc),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Financeiro / Controle de despesas'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => _mudarMes(-1),
                      ),
                      Text(
                        '${nomesDosMeses[_mes - 1].toUpperCase()} $_ano',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => _mudarMes(1),
                      ),
                    ],
                  ),
                  FilledButton.icon(
                    onPressed: () async {
                      final result = await Navigator.of(context)
                          .pushNamed('/lancar_despesa');
                      if (result == true) {
                        _recarregar();
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('LANÇAR DESPESA'),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'PAINEL'),
                Tab(text: 'CALENDÁRIO'),
                Tab(text: 'CADASTROS'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  PainelDeDespesas(onVerCalendario: () => _tabController.animateTo(1)),
                  const CalendarioDeDespesasBody(),
                  const CadastrosDeDespesasBody(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
