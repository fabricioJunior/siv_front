import 'dart:async';

import 'package:autenticacao/domain/usecases/recuperar_usuarios.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';

import '../../../domain/models/usuario.dart';

part 'usuarios_state.dart';
part 'usuarios_event.dart';

class UsuariosBloc extends Bloc<UsuariosEvent, UsuariosState> {
  final RecuperarUsuarios _recuperarUsuarios;

  UsuariosBloc(
    this._recuperarUsuarios,
  ) : super(const UsuariosNaoInicializados(usuarios: [])) {
    on<UsuariosIniciou>(_onUsuariosIniciou);
  }

  FutureOr<void> _onUsuariosIniciou(
      UsuariosIniciou event, Emitter<UsuariosState> emit) async {
    try {
      emit(UsuariosCarregarEmProgresso(state));
      var usuarios = await _recuperarUsuarios.call();
      emit(
        UsuariosCarregarSucesso.fromLastState(
          state,
          usuarios: usuarios.toList(),
        ),
      );
    } catch (e, s) {
      addError(e, s);
      emit(UsuariosCarregarFalha(state));
    }
  }
}
