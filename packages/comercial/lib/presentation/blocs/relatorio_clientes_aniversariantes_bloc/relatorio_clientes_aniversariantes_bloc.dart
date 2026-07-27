import 'dart:async';

import 'package:comercial/domain/models/relatorios.dart';
import 'package:comercial/domain/use_cases/get_relatorio_clientes_aniversariantes.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/sessao.dart';

part 'relatorio_clientes_aniversariantes_event.dart';
part 'relatorio_clientes_aniversariantes_state.dart';

class RelatorioClientesAniversariantesBloc extends Bloc<
    RelatorioClientesAniversariantesEvent,
    RelatorioClientesAniversariantesState> {
  final GetRelatorioClientesAniversariantes _useCase;

  RelatorioClientesAniversariantesBloc(this._useCase)
      : super(RelatorioClientesAniversariantesState.initial()) {
    on<RelatorioClientesAniversariantesCarregar>(_onCarregar);
  }

  FutureOr<void> _onCarregar(
    RelatorioClientesAniversariantesCarregar event,
    Emitter<RelatorioClientesAniversariantesState> emit,
  ) async {
    final empresaId = sl<IAcessoGlobalSessao>().empresaIdDaSessao;
    if (empresaId == null) return;
    try {
      emit(RelatorioClientesAniversariantesState(
        step: RelatorioClientesAniversariantesStep.carregando,
        dados: state.dados,
        mes: event.mes,
        dataUltimaCompraInicial: event.dataUltimaCompraInicial,
        dataUltimaCompraFinal: event.dataUltimaCompraFinal,
        page: event.page,
        totalPages: state.totalPages,
      ));
      final dados = await _useCase.call(
        empresaIds: [empresaId],
        mes: event.mes,
        dataUltimaCompraInicial: event.dataUltimaCompraInicial,
        dataUltimaCompraFinal: event.dataUltimaCompraFinal,
        page: event.page,
      );
      emit(RelatorioClientesAniversariantesState(
        step: RelatorioClientesAniversariantesStep.sucesso,
        dados: dados,
        mes: event.mes,
        dataUltimaCompraInicial: event.dataUltimaCompraInicial,
        dataUltimaCompraFinal: event.dataUltimaCompraFinal,
        page: event.page,
        totalPages: dados.meta.totalPages,
      ));
    } catch (e, s) {
      emit(RelatorioClientesAniversariantesState(
        step: RelatorioClientesAniversariantesStep.falha,
        erro: 'Falha ao carregar relatório de clientes aniversariantes.',
        mes: event.mes,
        dataUltimaCompraInicial: event.dataUltimaCompraInicial,
        dataUltimaCompraFinal: event.dataUltimaCompraFinal,
        page: event.page,
        totalPages: state.totalPages,
      ));
      addError(e, s);
    }
  }
}
