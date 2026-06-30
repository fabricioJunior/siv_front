import 'dart:async';

import 'package:comercial/domain/models/relatorios.dart';
import 'package:comercial/domain/use_cases/get_relatorio_clientes_ativos.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/sessao.dart';

part 'relatorio_clientes_event.dart';
part 'relatorio_clientes_state.dart';

class RelatorioClientesBloc
    extends Bloc<RelatorioClientesEvent, RelatorioClientesState> {
  final GetRelatorioClientesAtivos _useCase;

  RelatorioClientesBloc(this._useCase)
      : super(const RelatorioClientesState.initial()) {
    on<RelatorioClientesCarregar>(_onCarregar);
  }

  FutureOr<void> _onCarregar(
    RelatorioClientesCarregar event,
    Emitter<RelatorioClientesState> emit,
  ) async {
    final empresaId = sl<IAcessoGlobalSessao>().empresaIdDaSessao;
    if (empresaId == null) return;
    try {
      emit(state.copyWith(
        step: RelatorioClientesStep.carregando,
        dias: event.dias,
        dataReferencia: event.dataReferencia,
        page: event.page,
      ));
      final dados = await _useCase.call(
        empresaIds: [empresaId],
        dias: event.dias,
        dataReferencia: event.dataReferencia,
        page: event.page,
      );
      emit(state.copyWith(
        step: RelatorioClientesStep.sucesso,
        dados: dados,
        totalPages: dados.meta.totalPages,
      ));
    } catch (e, s) {
      emit(state.copyWith(
        step: RelatorioClientesStep.falha,
        erro: 'Falha ao carregar relatório de clientes ativos.',
      ));
      addError(e, s);
    }
  }
}
