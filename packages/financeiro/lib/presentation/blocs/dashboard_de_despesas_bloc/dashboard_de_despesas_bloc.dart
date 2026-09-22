import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:financeiro/domain/models/despesa_dashboard.dart';
import 'package:financeiro/use_cases.dart';

part 'dashboard_de_despesas_event.dart';
part 'dashboard_de_despesas_state.dart';

class DashboardDeDespesasBloc
    extends Bloc<DashboardDeDespesasEvent, DashboardDeDespesasState> {
  final RecuperarDashboardDeDespesas _recuperarDashboard;

  DashboardDeDespesasBloc(this._recuperarDashboard)
      : super(const DashboardDeDespesasInitial()) {
    on<DashboardDeDespesasIniciou>(_onIniciou);
  }

  FutureOr<void> _onIniciou(
    DashboardDeDespesasIniciou event,
    Emitter<DashboardDeDespesasState> emit,
  ) async {
    try {
      emit(
        DashboardDeDespesasCarregarEmProgresso(
          ano: event.ano,
          mes: event.mes,
        ),
      );

      final dashboard = await _recuperarDashboard.call(
        empresaId: event.empresaId,
        ano: event.ano,
        mes: event.mes,
      );

      emit(
        DashboardDeDespesasCarregarSucesso(
          ano: event.ano,
          mes: event.mes,
          dashboard: dashboard,
        ),
      );
    } catch (e, s) {
      emit(DashboardDeDespesasCarregarFalha(ano: event.ano, mes: event.mes));
      addError(e, s);
    }
  }
}
