import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:produtos/models.dart';
import 'package:produtos/use_cases.dart';

part 'referencia_event.dart';
part 'referencia_state.dart';

class ReferenciaBloc extends Bloc<ReferenciaEvent, ReferenciaState> {
  final RecuperarReferencia _recuperarReferencia;

  ReferenciaBloc(this._recuperarReferencia) : super(const ReferenciaInitial()) {
    on<ReferenciaIniciou>(_onReferenciaIniciou);
  }

  FutureOr<void> _onReferenciaIniciou(
    ReferenciaIniciou event,
    Emitter<ReferenciaState> emit,
  ) async {
    try {
      emit(const ReferenciaCarregarEmProgresso());
      final referencia = await _recuperarReferencia.call(
        id: event.idReferencia,
      );
      emit(ReferenciaCarregarSucesso(referencia: referencia));
    } catch (e, s) {
      emit(const ReferenciaCarregarFalha());
      addError(e, s);
    }
  }
}
