import 'dart:async';

import 'package:comercial/domain/models/relatorios.dart';
import 'package:comercial/domain/use_cases/get_relatorio_pontos_fidelidade.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/sessao.dart';

part 'relatorio_pontos_fidelidade_event.dart';
part 'relatorio_pontos_fidelidade_state.dart';

class RelatorioPontosFidelidadeBloc extends Bloc<
    RelatorioPontosFidelidadeEvent, RelatorioPontosFidelidadeState> {
  final GetRelatorioPontosFidelidade _useCase;

  RelatorioPontosFidelidadeBloc(this._useCase)
      : super(const RelatorioPontosFidelidadeState.initial()) {
    on<RelatorioPontosFidelidadeCarregar>(_onCarregar);
  }

  FutureOr<void> _onCarregar(
    RelatorioPontosFidelidadeCarregar event,
    Emitter<RelatorioPontosFidelidadeState> emit,
  ) async {
    final empresaId = sl<IAcessoGlobalSessao>().empresaIdDaSessao;
    if (empresaId == null) return;
    try {
      emit(state.copyWith(
        step: RelatorioPontosFidelidadeStep.carregando,
        situacaoCadastro: event.situacaoCadastro,
        limparSituacaoCadastro: event.situacaoCadastro == null,
        page: event.page,
      ));
      final dados = await _useCase.call(
        empresaIds: [empresaId],
        situacaoCadastro: event.situacaoCadastro,
        page: event.page,
      );
      emit(state.copyWith(
        step: RelatorioPontosFidelidadeStep.sucesso,
        dados: dados,
        totalPages: dados.meta.totalPages,
      ));
    } catch (e, s) {
      emit(state.copyWith(
        step: RelatorioPontosFidelidadeStep.falha,
        erro: 'Falha ao carregar relatório de pontos de fidelidade.',
      ));
      addError(e, s);
    }
  }
}
