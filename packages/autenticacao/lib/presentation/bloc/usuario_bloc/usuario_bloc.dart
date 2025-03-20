import 'dart:async';

import 'package:autenticacao/domain/usecases/recuperar_usuario.dart';
import 'package:autenticacao/models.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';

part 'usuario_event.dart';
part 'usuario_state.dart';

class UsuarioBloc extends Bloc<UsuarioEvent, UsuarioState> {
  final RecuperarUsuario _recuperarUsuario;

  UsuarioBloc(this._recuperarUsuario) : super(UsuarioNaoInicializado()) {
    on<UsuarioIniciou>(_onUsuarioIniciou);
  }

  FutureOr<void> _onUsuarioIniciou(
    UsuarioIniciou event,
    Emitter<UsuarioState> emit,
  ) async {
    try {
      emit(UsuarioCarregarEmProgresso());
      var usuario = await _recuperarUsuario(event.idUsuario);
      if (usuario == null) {
        emit(UsuarioCarregarFalha());
        return;
      }
      emit(UsuarioCarregarSucesso(usuario: usuario));
    } catch (e, s) {
      emit(UsuarioCarregarFalha());
      addError(e, s);
    }
  }
}
