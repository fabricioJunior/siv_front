import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:produtos/models.dart';
import 'package:produtos/use_cases.dart';

part 'referencias_pendentes_peso_event.dart';
part 'referencias_pendentes_peso_state.dart';

class ReferenciasPendentesPesoBloc extends Bloc<
    ReferenciasPendentesPesoEvent, ReferenciasPendentesPesoState> {
  final RecuperarReferenciasSemPeso _recuperarReferenciasSemPeso;
  final AtualizarDadosLogisticosEmMassa _atualizarDadosLogisticosEmMassa;

  ReferenciasPendentesPesoBloc(
    this._recuperarReferenciasSemPeso,
    this._atualizarDadosLogisticosEmMassa,
  ) : super(const ReferenciasPendentesPesoState()) {
    on<ReferenciasPendentesPesoIniciou>(_onIniciou);
    on<ReferenciasPendentesPesoBuscou>(_onBuscou);
    on<ReferenciasPendentesPesoCarregouMais>(_onCarregouMais);
    on<ReferenciasPendentesPesoAtualizouEmMassa>(_onAtualizouEmMassa);
  }

  FutureOr<void> _onIniciou(
    ReferenciasPendentesPesoIniciou event,
    Emitter<ReferenciasPendentesPesoState> emit,
  ) async {
    emit(state.copyWith(step: ReferenciasPendentesPesoStep.carregando, items: []));
    try {
      final resultado = await _recuperarReferenciasSemPeso.call(
        search: state.search,
        orderBy: state.orderBy,
        orderDir: state.orderDir,
        page: 1,
      );
      emit(state.copyWith(
        step: ReferenciasPendentesPesoStep.carregado,
        items: resultado.items,
        totalItems: resultado.totalItems,
        totalPages: resultado.totalPages,
        currentPage: resultado.currentPage,
      ));
    } catch (e, s) {
      emit(state.copyWith(step: ReferenciasPendentesPesoStep.falha));
      addError(e, s);
    }
  }

  FutureOr<void> _onBuscou(
    ReferenciasPendentesPesoBuscou event,
    Emitter<ReferenciasPendentesPesoState> emit,
  ) async {
    emit(state.copyWith(
      step: ReferenciasPendentesPesoStep.carregando,
      search: event.search,
      orderBy: event.orderBy ?? state.orderBy,
      orderDir: event.orderDir ?? state.orderDir,
      items: [],
    ));
    try {
      final resultado = await _recuperarReferenciasSemPeso.call(
        search: event.search,
        orderBy: event.orderBy ?? state.orderBy,
        orderDir: event.orderDir ?? state.orderDir,
        page: 1,
      );
      emit(state.copyWith(
        step: ReferenciasPendentesPesoStep.carregado,
        items: resultado.items,
        totalItems: resultado.totalItems,
        totalPages: resultado.totalPages,
        currentPage: resultado.currentPage,
      ));
    } catch (e, s) {
      emit(state.copyWith(step: ReferenciasPendentesPesoStep.falha));
      addError(e, s);
    }
  }

  FutureOr<void> _onCarregouMais(
    ReferenciasPendentesPesoCarregouMais event,
    Emitter<ReferenciasPendentesPesoState> emit,
  ) async {
    if (state.currentPage >= state.totalPages) return;
    emit(state.copyWith(step: ReferenciasPendentesPesoStep.carregandoMais));
    try {
      final proxPagina = state.currentPage + 1;
      final resultado = await _recuperarReferenciasSemPeso.call(
        search: state.search,
        orderBy: state.orderBy,
        orderDir: state.orderDir,
        page: proxPagina,
      );
      emit(state.copyWith(
        step: ReferenciasPendentesPesoStep.carregado,
        items: [...state.items, ...resultado.items],
        totalItems: resultado.totalItems,
        totalPages: resultado.totalPages,
        currentPage: resultado.currentPage,
      ));
    } catch (e, s) {
      emit(state.copyWith(step: ReferenciasPendentesPesoStep.carregado));
      addError(e, s);
    }
  }

  FutureOr<void> _onAtualizouEmMassa(
    ReferenciasPendentesPesoAtualizouEmMassa event,
    Emitter<ReferenciasPendentesPesoState> emit,
  ) async {
    emit(state.copyWith(
      step: ReferenciasPendentesPesoStep.atualizando,
      atualizadas: null,
      ignoradas: null,
    ));
    try {
      final resultado = await _atualizarDadosLogisticosEmMassa.call();
      emit(state.copyWith(
        step: ReferenciasPendentesPesoStep.atualizado,
        atualizadas: resultado.atualizadas,
        ignoradas: resultado.ignoradas,
      ));
      add(ReferenciasPendentesPesoIniciou());
    } catch (e, s) {
      emit(state.copyWith(step: ReferenciasPendentesPesoStep.falha));
      addError(e, s);
    }
  }
}
