import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:promocoes/domain/models/cupom.dart';
import 'package:promocoes/use_cases.dart';

part 'cupons_event.dart';
part 'cupons_state.dart';

class CuponsBloc extends Bloc<CuponsEvent, CuponsState> {
  final RecuperarCupons _recuperarCupons;

  CuponsBloc(this._recuperarCupons) : super(const CuponsInitial()) {
    on<CuponsIniciou>(_onIniciou);
  }

  FutureOr<void> _onIniciou(
    CuponsIniciou event,
    Emitter<CuponsState> emit,
  ) async {
    try {
      emit(CuponsCarregarEmProgresso(cupons: state.cupons));

      final cupons = await _recuperarCupons.call(codigo: event.busca);

      emit(CuponsCarregarSucesso(cupons: cupons));
    } catch (e, s) {
      emit(CuponsCarregarFalha(cupons: state.cupons));
      addError(e, s);
    }
  }
}
