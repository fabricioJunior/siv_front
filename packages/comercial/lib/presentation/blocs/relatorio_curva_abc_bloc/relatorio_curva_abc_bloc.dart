import 'dart:async';

import 'package:comercial/domain/models/relatorios.dart';
import 'package:comercial/domain/use_cases/get_relatorio_curva_abc.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/sessao.dart';

part 'relatorio_curva_abc_event.dart';
part 'relatorio_curva_abc_state.dart';

class RelatorioCurvaAbcBloc
    extends Bloc<RelatorioCurvaAbcEvent, RelatorioCurvaAbcState> {
  final GetRelatorioCurvaAbc _useCase;

  RelatorioCurvaAbcBloc(this._useCase)
      : super(RelatorioCurvaAbcState.initial()) {
    on<RelatorioCurvaAbcCarregar>(_onCarregar);
  }

  FutureOr<void> _onCarregar(
    RelatorioCurvaAbcCarregar event,
    Emitter<RelatorioCurvaAbcState> emit,
  ) async {
    final empresaId = sl<IAcessoGlobalSessao>().empresaIdDaSessao;
    if (empresaId == null) return;
    try {
      emit(state.copyWith(
        step: RelatorioCurvaAbcStep.carregando,
        dataInicial: event.dataInicial,
        dataFinal: event.dataFinal,
        page: event.page,
      ));
      final dados = await _useCase.call(
        empresaIds: [empresaId],
        dataInicial: event.dataInicial,
        dataFinal: event.dataFinal,
        page: event.page,
      );
      emit(state.copyWith(
        step: RelatorioCurvaAbcStep.sucesso,
        dados: dados,
        totalPages: dados.meta.totalPages,
      ));
    } catch (e, s) {
      emit(state.copyWith(
        step: RelatorioCurvaAbcStep.falha,
        erro: 'Falha ao carregar curva ABC.',
      ));
      addError(e, s);
    }
  }
}
