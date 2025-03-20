part of 'usuarios_bloc.dart';

abstract class UsuariosState extends Equatable {
  final List<Usuario> usuarios;

  const UsuariosState({required this.usuarios});

  UsuariosState.fromLastState(
    UsuariosState state, {
    List<Usuario>? usuarios,
  }) : usuarios = usuarios ?? state.usuarios;

  @override
  List<Object?> get props => [usuarios];
}

class UsuariosNaoInicializados extends UsuariosState {
  const UsuariosNaoInicializados({required super.usuarios});
}

class UsuariosCarregarEmProgresso extends UsuariosState {
  UsuariosCarregarEmProgresso(super.state) : super.fromLastState();
}

class UsuariosCarregarSucesso extends UsuariosState {
  UsuariosCarregarSucesso.fromLastState(
    super.state, {
    required super.usuarios,
  }) : super.fromLastState();
}

class UsuariosCarregarFalha extends UsuariosState {
  UsuariosCarregarFalha(super.state) : super.fromLastState();
}
