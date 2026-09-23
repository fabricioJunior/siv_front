part of 'dashboard_de_despesas_bloc.dart';

abstract class DashboardDeDespesasEvent {}

class DashboardDeDespesasIniciou extends DashboardDeDespesasEvent {
  final int empresaId;
  final int ano;
  final int mes;

  DashboardDeDespesasIniciou({
    required this.empresaId,
    required this.ano,
    required this.mes,
  });
}
