import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:produtos/models.dart';
import 'package:produtos/use_cases.dart';

part 'referencias_pendentes_ncm_event.dart';
part 'referencias_pendentes_ncm_state.dart';

class ReferenciasPendentesNcmBloc
    extends Bloc<ReferenciasPendentesNcmEvent, ReferenciasPendentesNcmState> {
  final RecuperarReferenciasSemNcm _recuperarReferenciasSemNcm;
  final AtualizarNcmEmMassa _atualizarNcmEmMassa;

  ReferenciasPendentesNcmBloc(
    this._recuperarReferenciasSemNcm,
    this._atualizarNcmEmMassa,
  ) : super(const ReferenciasPendentesNcmState()) {
    on<ReferenciasPendentesNcmIniciou>(_onIniciou);
    on<ReferenciasPendentesNcmBuscou>(_onBuscou);
    on<ReferenciasPendentesNcmCarregouMais>(_onCarregouMais);
    on<ReferenciasPendentesNcmAtualizouEmMassa>(_onAtualizouEmMassa);
  }

  FutureOr<void> _onIniciou(
    ReferenciasPendentesNcmIniciou event,
    Emitter<ReferenciasPendentesNcmState> emit,
  ) async {
    emit(state.copyWith(step: ReferenciasPendentesNcmStep.carregando, items: []));
    try {
      final resultado = await _recuperarReferenciasSemNcm.call(
        search: state.search,
        orderBy: state.orderBy,
        orderDir: state.orderDir,
        page: 1,
      );
      emit(state.copyWith(
        step: ReferenciasPendentesNcmStep.carregado,
        items: resultado.items,
        totalItems: resultado.totalItems,
        totalPages: resultado.totalPages,
        currentPage: resultado.currentPage,
      ));
    } catch (e, s) {
      emit(state.copyWith(step: ReferenciasPendentesNcmStep.falha));
      addError(e, s);
    }
  }

  FutureOr<void> _onBuscou(
    ReferenciasPendentesNcmBuscou event,
    Emitter<ReferenciasPendentesNcmState> emit,
  ) async {
    emit(state.copyWith(
      step: ReferenciasPendentesNcmStep.carregando,
      search: event.search,
      orderBy: event.orderBy ?? state.orderBy,
      orderDir: event.orderDir ?? state.orderDir,
      items: [],
    ));
    try {
      final resultado = await _recuperarReferenciasSemNcm.call(
        search: event.search,
        orderBy: event.orderBy ?? state.orderBy,
        orderDir: event.orderDir ?? state.orderDir,
        page: 1,
      );
      emit(state.copyWith(
        step: ReferenciasPendentesNcmStep.carregado,
        items: resultado.items,
        totalItems: resultado.totalItems,
        totalPages: resultado.totalPages,
        currentPage: resultado.currentPage,
      ));
    } catch (e, s) {
      emit(state.copyWith(step: ReferenciasPendentesNcmStep.falha));
      addError(e, s);
    }
  }

  FutureOr<void> _onCarregouMais(
    ReferenciasPendentesNcmCarregouMais event,
    Emitter<ReferenciasPendentesNcmState> emit,
  ) async {
    if (state.currentPage >= state.totalPages) return;
    emit(state.copyWith(step: ReferenciasPendentesNcmStep.carregandoMais));
    try {
      final proxPagina = state.currentPage + 1;
      final resultado = await _recuperarReferenciasSemNcm.call(
        search: state.search,
        orderBy: state.orderBy,
        orderDir: state.orderDir,
        page: proxPagina,
      );
      emit(state.copyWith(
        step: ReferenciasPendentesNcmStep.carregado,
        items: [...state.items, ...resultado.items],
        totalItems: resultado.totalItems,
        totalPages: resultado.totalPages,
        currentPage: resultado.currentPage,
      ));
    } catch (e, s) {
      emit(state.copyWith(step: ReferenciasPendentesNcmStep.carregado));
      addError(e, s);
    }
  }

  FutureOr<void> _onAtualizouEmMassa(
    ReferenciasPendentesNcmAtualizouEmMassa event,
    Emitter<ReferenciasPendentesNcmState> emit,
  ) async {
    emit(state.copyWith(
      step: ReferenciasPendentesNcmStep.atualizando,
      atualizadas: null,
      ignoradas: null,
    ));
    try {
      final resultado = await _atualizarNcmEmMassa.call();
      emit(state.copyWith(
        step: ReferenciasPendentesNcmStep.atualizado,
        atualizadas: resultado.atualizadas,
        ignoradas: resultado.ignoradas,
      ));
      // Reload after mass update
      add(ReferenciasPendentesNcmIniciou());
    } catch (e, s) {
      emit(state.copyWith(step: ReferenciasPendentesNcmStep.falha));
      addError(e, s);
    }
  }
}
