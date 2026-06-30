import 'dart:async';

import 'package:comercial/domain/models/relatorios.dart';
import 'package:comercial/domain/use_cases/get_relatorio_faturamento.dart';
import 'package:core/bloc.dart';
import 'package:core/sessao.dart';
import 'package:core/injecoes.dart';

part 'relatorio_faturamento_event.dart';
part 'relatorio_faturamento_state.dart';

class RelatorioFaturamentoBloc
    extends Bloc<RelatorioFaturamentoEvent, RelatorioFaturamentoState> {
  final GetRelatorioFaturamento _useCase;

  RelatorioFaturamentoBloc(this._useCase)
      : super(RelatorioFaturamentoState.initial()) {
    on<RelatorioFaturamentoCarregar>(_onCarregar);
  }

  FutureOr<void> _onCarregar(
    RelatorioFaturamentoCarregar event,
    Emitter<RelatorioFaturamentoState> emit,
  ) async {
    final empresaId = sl<IAcessoGlobalSessao>().empresaIdDaSessao;
    if (empresaId == null) return;
    try {
      emit(state.copyWith(
        step: RelatorioFaturamentoStep.carregando,
        dataInicial: event.dataInicial,
        dataFinal: event.dataFinal,
      ));
      final dados = await _useCase.call(
        empresaIds: [empresaId],
        dataInicial: event.dataInicial,
        dataFinal: event.dataFinal,
      );
      emit(state.copyWith(
        step: RelatorioFaturamentoStep.sucesso,
        dados: dados,
      ));
    } catch (e, s) {
      emit(state.copyWith(
        step: RelatorioFaturamentoStep.falha,
        erro: 'Falha ao carregar relatório de faturamento.',
      ));
      addError(e, s);
    }
  }
}
