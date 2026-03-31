import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:financeiro/domain/models/forma_de_pagamento.dart';
import 'package:financeiro/use_cases.dart';

part 'formas_de_pagamento_event.dart';
part 'formas_de_pagamento_state.dart';

class FormasDePagamentoBloc
    extends Bloc<FormasDePagamentoEvent, FormasDePagamentoState> {
  final RecuperarFormasDePagamento _recuperarFormasDePagamento;

  FormasDePagamentoBloc(this._recuperarFormasDePagamento)
      : super(const FormasDePagamentoInitial()) {
    on<FormasDePagamentoIniciou>(_onIniciou);
  }

  FutureOr<void> _onIniciou(
    FormasDePagamentoIniciou event,
    Emitter<FormasDePagamentoState> emit,
  ) async {
    try {
      emit(
        FormasDePagamentoCarregarEmProgresso(
          formasDePagamento: state.formasDePagamento,
        ),
      );

      final formas = await _recuperarFormasDePagamento.call(
        filtro: event.busca,
      );

      emit(
        FormasDePagamentoCarregarSucesso(
          formasDePagamento: formas,
        ),
      );
    } catch (e, s) {
      emit(
        FormasDePagamentoCarregarFalha(
          formasDePagamento: state.formasDePagamento,
        ),
      );
      addError(e, s);
    }
  }
}
