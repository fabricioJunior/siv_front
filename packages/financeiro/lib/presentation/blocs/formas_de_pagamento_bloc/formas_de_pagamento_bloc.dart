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
    on<FormasDePagamentoFiltroTipoOperacaoAlterado>(
      _onFiltroTipoOperacaoAlterado,
    );
  }

  FutureOr<void> _onIniciou(
    FormasDePagamentoIniciou event,
    Emitter<FormasDePagamentoState> emit,
  ) async {
    try {
      emit(
        FormasDePagamentoCarregarEmProgresso(
          formasDePagamento: state.formasDePagamento,
          tipoOperacaoFiltro: state.tipoOperacaoFiltro,
        ),
      );

      final formas = await _recuperarFormasDePagamento.call(
        filtro: event.busca,
      );

      emit(
        FormasDePagamentoCarregarSucesso(
          formasDePagamento: formas,
          tipoOperacaoFiltro: state.tipoOperacaoFiltro,
        ),
      );
    } catch (e, s) {
      emit(
        FormasDePagamentoCarregarFalha(
          formasDePagamento: state.formasDePagamento,
          tipoOperacaoFiltro: state.tipoOperacaoFiltro,
        ),
      );
      addError(e, s);
    }
  }

  FutureOr<void> _onFiltroTipoOperacaoAlterado(
    FormasDePagamentoFiltroTipoOperacaoAlterado event,
    Emitter<FormasDePagamentoState> emit,
  ) {
    emit(
      FormasDePagamentoCarregarSucesso(
        formasDePagamento: state.formasDePagamento,
        tipoOperacaoFiltro: event.tipoOperacao,
      ),
    );
  }
}
