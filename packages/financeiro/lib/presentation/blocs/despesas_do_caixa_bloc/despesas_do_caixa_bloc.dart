import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/remote_data_sourcers.dart';
import 'package:financeiro/models.dart';
import 'package:financeiro/use_cases.dart';

part 'despesas_do_caixa_event.dart';
part 'despesas_do_caixa_state.dart';

class DespesasDoCaixaBloc extends Bloc<DespesasDoCaixaEvent, DespesasDoCaixaState> {
  final RecuperarDespesasDoCaixa _recuperarDespesas;
  final CancelarDespesaDoCaixa _cancelarDespesa;

  DespesasDoCaixaBloc(this._recuperarDespesas, this._cancelarDespesa)
      : super(const DespesasDoCaixaState.initial()) {
    on<DespesasDoCaixaIniciou>(_onIniciou);
    on<DespesasDoCaixaRecarregarSolicitado>(_onRecarregarSolicitado);
    on<DespesaDoCaixaExclusaoSolicitada>(_onExclusaoSolicitada);
  }

  FutureOr<void> _onIniciou(
    DespesasDoCaixaIniciou event,
    Emitter<DespesasDoCaixaState> emit,
  ) async {
    emit(state.copyWith(caixaId: event.caixaId, erro: null));
    await _carregarDespesas(event.caixaId, emit);
  }

  FutureOr<void> _onRecarregarSolicitado(
    DespesasDoCaixaRecarregarSolicitado event,
    Emitter<DespesasDoCaixaState> emit,
  ) async {
    final caixaId = state.caixaId;
    if (caixaId == null) {
      return;
    }

    await _carregarDespesas(caixaId, emit);
  }

  FutureOr<void> _onExclusaoSolicitada(
    DespesaDoCaixaExclusaoSolicitada event,
    Emitter<DespesasDoCaixaState> emit,
  ) async {
    final caixaId = state.caixaId;
    if (caixaId == null) {
      emit(
        state.copyWith(
          step: DespesasDoCaixaStep.falha,
          erro: 'Não foi possível identificar o caixa desta despesa.',
        ),
      );
      return;
    }

    try {
      emit(state.copyWith(step: DespesasDoCaixaStep.cancelando, erro: null));

      await _cancelarDespesa.call(
        caixaId: caixaId,
        despesaId: event.despesaId,
        motivo: event.motivo,
      );

      final despesas = await _recuperarDespesas.call(caixaId: caixaId);
      emit(
        state.copyWith(
          despesas: _ordenar(despesas),
          step: DespesasDoCaixaStep.cancelado,
          erro: null,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: DespesasDoCaixaStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao cancelar a despesa. Tente novamente.'),
        ),
      );
      addError(e, s);
    }
  }

  Future<void> _carregarDespesas(
    int caixaId,
    Emitter<DespesasDoCaixaState> emit,
  ) async {
    try {
      emit(state.copyWith(step: DespesasDoCaixaStep.carregando, erro: null));

      final despesas = await _recuperarDespesas.call(caixaId: caixaId);

      emit(
        state.copyWith(
          despesas: _ordenar(despesas),
          step: DespesasDoCaixaStep.sucesso,
          erro: null,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: DespesasDoCaixaStep.falha,
          erro: 'Falha ao carregar as despesas deste caixa.',
        ),
      );
      addError(e, s);
    }
  }

  List<DespesaDoCaixa> _ordenar(List<DespesaDoCaixa> despesas) {
    final itens = [...despesas];
    itens.sort((a, b) => b.id.compareTo(a.id));
    return itens;
  }
}
