import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:financeiro/domain/models/origem_pagamento_despesa.dart';
import 'package:financeiro/use_cases.dart';

part 'origens_pagamento_despesa_event.dart';
part 'origens_pagamento_despesa_state.dart';

class OrigensPagamentoDespesaBloc
    extends Bloc<OrigensPagamentoDespesaEvent, OrigensPagamentoDespesaState> {
  final RecuperarOrigensPagamentoDespesa _recuperarOrigens;

  OrigensPagamentoDespesaBloc(this._recuperarOrigens)
      : super(const OrigensPagamentoDespesaInitial()) {
    on<OrigensPagamentoDespesaIniciou>(_onIniciou);
  }

  FutureOr<void> _onIniciou(
    OrigensPagamentoDespesaIniciou event,
    Emitter<OrigensPagamentoDespesaState> emit,
  ) async {
    try {
      emit(OrigensPagamentoDespesaCarregarEmProgresso(origens: state.origens));

      final origens = await _recuperarOrigens.call(
        empresaId: event.empresaId,
        filtro: event.busca,
      );

      emit(OrigensPagamentoDespesaCarregarSucesso(origens: origens));
    } catch (e, s) {
      emit(OrigensPagamentoDespesaCarregarFalha(origens: state.origens));
      addError(e, s);
    }
  }
}
