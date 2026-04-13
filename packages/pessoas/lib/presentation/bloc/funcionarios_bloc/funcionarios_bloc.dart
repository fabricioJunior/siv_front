import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:pessoas/models.dart';
import 'package:pessoas/uses_cases.dart';

part 'funcionarios_event.dart';
part 'funcionarios_state.dart';

class FuncionariosBloc extends Bloc<FuncionariosEvent, FuncionariosState> {
  final RecuperarFuncionarios _recuperarFuncionarios;
  final RecuperarFuncionario _recuperarFuncionario;

  FuncionariosBloc(this._recuperarFuncionarios, this._recuperarFuncionario)
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
      final funcionario = event.idFuncionarioSelecionado != null
          ? await _recuperarFuncionario(
              idFuncionario: event.idFuncionarioSelecionado!)
          : null;
      emit(FuncionariosCarregarSucesso(
          funcionarios: funcionarios.toList(),
          funcionarioSelecionado: funcionario));
    } catch (e, s) {
      emit(const FuncionariosCarregarFalha());
      addError(e, s);
    }
  }
}
