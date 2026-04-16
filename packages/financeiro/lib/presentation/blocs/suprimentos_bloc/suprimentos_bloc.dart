import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:financeiro/models.dart';
import 'package:financeiro/use_cases.dart';

part 'suprimentos_event.dart';
part 'suprimentos_state.dart';

class SuprimentosBloc extends Bloc<SuprimentosEvent, SuprimentosState> {
  final RecuperarSuprimentos _recuperarSuprimentos;
  final CancelarSuprimento _cancelarSuprimento;

  SuprimentosBloc(this._recuperarSuprimentos, this._cancelarSuprimento)
      : super(const SuprimentosState.initial()) {
    on<SuprimentosIniciou>(_onIniciou);
    on<SuprimentosRecarregarSolicitado>(_onRecarregarSolicitado);
    on<SuprimentoExclusaoSolicitada>(_onExclusaoSolicitada);
  }

  FutureOr<void> _onIniciou(
    SuprimentosIniciou event,
    Emitter<SuprimentosState> emit,
  ) async {
    emit(state.copyWith(caixaId: event.caixaId, erro: null));
    await _carregarSuprimentos(event.caixaId, emit);
  }

  FutureOr<void> _onRecarregarSolicitado(
    SuprimentosRecarregarSolicitado event,
    Emitter<SuprimentosState> emit,
  ) async {
    final caixaId = state.caixaId;
    if (caixaId == null) {
      return;
    }

    await _carregarSuprimentos(caixaId, emit);
  }

  FutureOr<void> _onExclusaoSolicitada(
    SuprimentoExclusaoSolicitada event,
    Emitter<SuprimentosState> emit,
  ) async {
    final caixaId = state.caixaId;
    if (caixaId == null) {
      emit(
        state.copyWith(
          step: SuprimentosStep.falha,
          erro: 'Não foi possível identificar o caixa deste suprimento.',
        ),
      );
      return;
    }

    try {
      emit(state.copyWith(step: SuprimentosStep.cancelando, erro: null));

      await _cancelarSuprimento.call(
        caixaId: caixaId,
        suprimentoId: event.suprimentoId,
        motivo: event.motivo,
      );

      final suprimentos = await _recuperarSuprimentos.call(caixaId: caixaId);
      emit(
        state.copyWith(
          suprimentos: _ordenar(suprimentos),
          step: SuprimentosStep.cancelado,
          erro: null,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: SuprimentosStep.falha,
          erro: 'Falha ao excluir o suprimento. Tente novamente.',
        ),
      );
      addError(e, s);
    }
  }

  Future<void> _carregarSuprimentos(
    int caixaId,
    Emitter<SuprimentosState> emit,
  ) async {
    try {
      emit(state.copyWith(step: SuprimentosStep.carregando, erro: null));

      final suprimentos = await _recuperarSuprimentos.call(caixaId: caixaId);

      emit(
        state.copyWith(
          suprimentos: _ordenar(suprimentos),
          step: SuprimentosStep.sucesso,
          erro: null,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: SuprimentosStep.falha,
          erro: 'Falha ao carregar os suprimentos deste caixa.',
        ),
      );
      addError(e, s);
    }
  }

  List<Suprimento> _ordenar(List<Suprimento> suprimentos) {
    final itens = [...suprimentos];
    itens.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
    return itens;
  }
}
