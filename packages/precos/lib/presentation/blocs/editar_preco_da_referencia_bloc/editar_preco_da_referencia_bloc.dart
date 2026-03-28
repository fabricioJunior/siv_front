import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:precos/use_cases.dart';

part 'editar_preco_da_referencia_event.dart';
part 'editar_preco_da_referencia_state.dart';

class EditarPrecoDaReferenciaBloc
    extends Bloc<EditarPrecoDaReferenciaEvent, EditarPrecoDaReferenciaState> {
  final AtualizarPrecoDaReferencia _atualizarPrecoDaReferencia;

  EditarPrecoDaReferenciaBloc(this._atualizarPrecoDaReferencia)
    : super(
        const EditarPrecoDaReferenciaState(
          step: EditarPrecoDaReferenciaStep.inicial,
        ),
      ) {
    on<EditarPrecoDaReferenciaSalvou>(_onEditarPrecoDaReferenciaSalvou);
  }

  FutureOr<void> _onEditarPrecoDaReferenciaSalvou(
    EditarPrecoDaReferenciaSalvou event,
    Emitter<EditarPrecoDaReferenciaState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          step: EditarPrecoDaReferenciaStep.salvando,
          clearErro: true,
        ),
      );

      await _atualizarPrecoDaReferencia.call(
        tabelaDePrecoId: event.tabelaDePrecoId,
        referenciaId: event.referenciaId,
        valor: event.valor,
      );

      emit(
        state.copyWith(
          step: EditarPrecoDaReferenciaStep.sucesso,
          clearErro: true,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: EditarPrecoDaReferenciaStep.falha,
          erro: 'Erro ao atualizar preço da referência.',
        ),
      );
      addError(e, s);
    }
  }
}
