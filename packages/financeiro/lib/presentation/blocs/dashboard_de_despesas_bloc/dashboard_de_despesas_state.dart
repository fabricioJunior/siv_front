part of 'dashboard_de_despesas_bloc.dart';

abstract class DashboardDeDespesasState extends Equatable {
  final int ano;
  final int mes;
  final DespesaDashboard? dashboard;

  const DashboardDeDespesasState({
    required this.ano,
    required this.mes,
    this.dashboard,
  });

  @override
  List<Object?> get props => [ano, mes, dashboard];
}

class DashboardDeDespesasInitial extends DashboardDeDespesasState {
  const DashboardDeDespesasInitial() : super(ano: 0, mes: 0);
}

class DashboardDeDespesasCarregarEmProgresso extends DashboardDeDespesasState {
  const DashboardDeDespesasCarregarEmProgresso({
    required super.ano,
    required super.mes,
  });
}

class DashboardDeDespesasCarregarSucesso extends DashboardDeDespesasState {
  const DashboardDeDespesasCarregarSucesso({
    required super.ano,
    required super.mes,
    required DespesaDashboard super.dashboard,
  });
}

class DashboardDeDespesasCarregarFalha extends DashboardDeDespesasState {
  const DashboardDeDespesasCarregarFalha({
    required super.ano,
    required super.mes,
  });
}
