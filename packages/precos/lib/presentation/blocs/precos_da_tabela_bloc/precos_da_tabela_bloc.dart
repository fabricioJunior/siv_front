import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:precos/models.dart';
import 'package:precos/use_cases.dart';

part 'precos_da_tabela_event.dart';
part 'precos_da_tabela_state.dart';

class PrecosDaTabelaBloc
    extends Bloc<PrecosDaTabelaEvent, PrecosDaTabelaState> {
  final RecuperarPrecosDasReferencias _recuperarPrecosDasReferencias;
  final RemoverPrecoDaReferencia _removerPrecoDaReferencia;

  PrecosDaTabelaBloc(
    this._recuperarPrecosDasReferencias,
    this._removerPrecoDaReferencia,
  ) : super(const PrecosDaTabelaState(step: PrecosDaTabelaStep.inicial)) {
    on<PrecosDaTabelaIniciou>(_onPrecosDaTabelaIniciou);
    on<PrecoDaTabelaRemoverSolicitado>(_onPrecoDaTabelaRemoverSolicitado);
  }

  FutureOr<void> _onPrecosDaTabelaIniciou(
    PrecosDaTabelaIniciou event,
    Emitter<PrecosDaTabelaState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          step: PrecosDaTabelaStep.carregando,
          tabelaDePrecoId: event.tabelaDePrecoId,
          clearErro: true,
        ),
      );

      final precos = await _recuperarPrecosDasReferencias.call(
        tabelaDePrecoId: event.tabelaDePrecoId,
      );

      emit(
        state.copyWith(
          step: PrecosDaTabelaStep.carregado,
          tabelaDePrecoId: event.tabelaDePrecoId,
          precos: precos,
          clearErro: true,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: PrecosDaTabelaStep.falha,
          erro: 'Erro ao carregar preços da tabela.',
        ),
      );
      addError(e, s);
    }
  }

  FutureOr<void> _onPrecoDaTabelaRemoverSolicitado(
    PrecoDaTabelaRemoverSolicitado event,
    Emitter<PrecosDaTabelaState> emit,
  ) async {
    final tabelaDePrecoId = state.tabelaDePrecoId;
    if (tabelaDePrecoId == null) {
      return;
    }

    try {
      emit(state.copyWith(step: PrecosDaTabelaStep.salvando, clearErro: true));

      await _removerPrecoDaReferencia.call(
        tabelaDePrecoId: tabelaDePrecoId,
        referenciaId: event.referenciaId,
      );

      final lista = state.precos
          .where((preco) => preco.referenciaId != event.referenciaId)
          .toList();

      emit(
        state.copyWith(
          step: PrecosDaTabelaStep.carregado,
          precos: lista,
          clearErro: true,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: PrecosDaTabelaStep.falha,
          erro: 'Erro ao remover preço da referência.',
        ),
      );
      addError(e, s);
    }
  }
}
