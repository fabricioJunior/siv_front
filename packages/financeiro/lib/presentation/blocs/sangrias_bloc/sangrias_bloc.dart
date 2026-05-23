import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:financeiro/models.dart';
import 'package:financeiro/use_cases.dart';

part 'sangrias_event.dart';
part 'sangrias_state.dart';

class SangriasBloc extends Bloc<SangriasEvent, SangriasState> {
  final RecuperarSangrias _recuperarSangrias;
  final CancelarSangria _cancelarSangria;

  SangriasBloc(this._recuperarSangrias, this._cancelarSangria)
      : super(const SangriasState.initial()) {
    on<SangriasIniciou>(_onIniciou);
    on<SangriasRecarregarSolicitado>(_onRecarregarSolicitado);
    on<SangriaExclusaoSolicitada>(_onExclusaoSolicitada);
  }

  FutureOr<void> _onIniciou(
    SangriasIniciou event,
    Emitter<SangriasState> emit,
  ) async {
    emit(state.copyWith(caixaId: event.caixaId, erro: null));
    await _carregarSangrias(event.caixaId, emit);
  }

  FutureOr<void> _onRecarregarSolicitado(
    SangriasRecarregarSolicitado event,
    Emitter<SangriasState> emit,
  ) async {
    final caixaId = state.caixaId;
    if (caixaId == null) {
      return;
    }

    await _carregarSangrias(caixaId, emit);
  }

  FutureOr<void> _onExclusaoSolicitada(
    SangriaExclusaoSolicitada event,
    Emitter<SangriasState> emit,
  ) async {
    final caixaId = state.caixaId;
    if (caixaId == null) {
      emit(
        state.copyWith(
          step: SangriasStep.falha,
          erro: 'Não foi possível identificar o caixa desta sangria.',
        ),
      );
      return;
    }

    try {
      emit(state.copyWith(step: SangriasStep.cancelando, erro: null));

      await _cancelarSangria.call(
        caixaId: caixaId,
        sangriaId: event.sangriaId,
        motivo: event.motivo,
      );

      final sangrias = await _recuperarSangrias.call(caixaId: caixaId);
      emit(
        state.copyWith(
          sangrias: _ordenar(sangrias),
          step: SangriasStep.cancelado,
          erro: null,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: SangriasStep.falha,
          erro: 'Falha ao excluir a sangria. Tente novamente.',
        ),
      );
      addError(e, s);
    }
  }

  Future<void> _carregarSangrias(
    int caixaId,
    Emitter<SangriasState> emit,
  ) async {
    try {
      emit(state.copyWith(step: SangriasStep.carregando, erro: null));

      final sangrias = await _recuperarSangrias.call(caixaId: caixaId);

      emit(
        state.copyWith(
          sangrias: _ordenar(sangrias),
          step: SangriasStep.sucesso,
          erro: null,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: SangriasStep.falha,
          erro: 'Falha ao carregar as sangrias deste caixa.',
        ),
      );
      addError(e, s);
    }
  }

  List<Sangria> _ordenar(List<Sangria> sangrias) {
    final itens = [...sangrias];
    itens.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
    return itens;
  }
}
