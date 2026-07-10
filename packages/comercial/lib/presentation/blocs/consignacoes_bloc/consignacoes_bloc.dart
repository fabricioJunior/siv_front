import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/remote_data_sourcers.dart';

part 'consignacoes_event.dart';
part 'consignacoes_state.dart';

class ConsignacoesBloc extends Bloc<ConsignacoesEvent, ConsignacoesState> {
  final RecuperarConsignacoes _recuperarConsignacoes;

  ConsignacoesBloc(this._recuperarConsignacoes)
      : super(const ConsignacoesState()) {
    on<ConsignacoesIniciou>(_onIniciou);
  }

  FutureOr<void> _onIniciou(
    ConsignacoesIniciou event,
    Emitter<ConsignacoesState> emit,
  ) async {
    emit(state.copyWith(step: ConsignacoesStep.carregando, erro: null));

    try {
      final consignacoes = await _recuperarConsignacoes.call(
        situacoes: event.situacoes,
      );
      emit(
        state.copyWith(
          step: ConsignacoesStep.sucesso,
          consignacoes: consignacoes,
          erro: null,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: ConsignacoesStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao carregar as consignações.'),
        ),
      );
      addError(e, s);
    }
  }
}
