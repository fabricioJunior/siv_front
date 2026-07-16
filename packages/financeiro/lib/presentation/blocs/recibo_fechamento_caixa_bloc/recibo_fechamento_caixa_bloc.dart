import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:financeiro/models.dart';
import 'package:financeiro/use_cases.dart';

part 'recibo_fechamento_caixa_event.dart';
part 'recibo_fechamento_caixa_state.dart';

class ReciboFechamentoCaixaBloc
    extends Bloc<ReciboFechamentoCaixaEvent, ReciboFechamentoCaixaState> {
  final RecuperarReciboFechamentoCaixa _recuperarRecibo;

  ReciboFechamentoCaixaBloc(this._recuperarRecibo)
      : super(const ReciboFechamentoCaixaState.initial()) {
    on<ReciboFechamentoCaixaIniciou>(_onIniciou);
  }

  FutureOr<void> _onIniciou(
    ReciboFechamentoCaixaIniciou event,
    Emitter<ReciboFechamentoCaixaState> emit,
  ) async {
    emit(
      state.copyWith(
        step: ReciboFechamentoCaixaStep.carregando,
        erro: null,
      ),
    );

    try {
      final recibo = await _recuperarRecibo(caixaId: event.caixaId);
      emit(
        state.copyWith(
          recibo: recibo,
          step: ReciboFechamentoCaixaStep.sucesso,
          erro: null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          step: ReciboFechamentoCaixaStep.falha,
          erro: 'Falha ao carregar o recibo de fechamento. Tente novamente.',
        ),
      );
    }
  }
}
