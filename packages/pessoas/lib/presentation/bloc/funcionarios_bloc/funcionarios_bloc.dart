import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:pessoas/models.dart';
import 'package:pessoas/uses_cases.dart';

part 'funcionarios_event.dart';
part 'funcionarios_state.dart';

class FuncionariosBloc extends Bloc<FuncionariosEvent, FuncionariosState> {
  final RecuperarFuncionarios _recuperarFuncionarios;

  FuncionariosBloc(this._recuperarFuncionarios)
      : super(const FuncionariosInitial()) {
    on<FuncionariosIniciou>(_onFuncionariosIniciou);
  }

  FutureOr<void> _onFuncionariosIniciou(
    FuncionariosIniciou event,
    Emitter<FuncionariosState> emit,
  ) async {
    try {
      emit(const FuncionariosCarregarEmProgresso());
      final funcionarios = await _recuperarFuncionarios.call();
      emit(FuncionariosCarregarSucesso(funcionarios: funcionarios.toList()));
    } catch (e, s) {
      emit(const FuncionariosCarregarFalha());
      addError(e, s);
    }
  }
}
