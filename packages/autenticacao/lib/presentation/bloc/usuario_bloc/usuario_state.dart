part of 'usuario_bloc.dart';

abstract class UsuarioState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UsuarioNaoInicializado extends UsuarioState {}

class UsuarioCarregarEmProgresso extends UsuarioState {}

class UsuarioCarregarSucesso extends UsuarioState {
  final Usuario usuario;

  UsuarioCarregarSucesso({required this.usuario});

  @override
  List<Object?> get props => [usuario];
}

class UsuarioCarregarFalha extends UsuarioState {}

class UsuarioEditarEmProgresso extends UsuarioState {
  final String? nome;
  final String? login;
  final String? senha;
  final String? tipo;

  UsuarioEditarEmProgresso(Usuario usuario)
      : nome = usuario.nome,
        login = usuario.login,
        senha = null,
        tipo = usuario.tipo;

  UsuarioEditarEmProgresso.fromLastState(
    UsuarioEditarEmProgresso state, {
    String? nome,
    String? login,
    String? senha,
    String? tipo,
  })  : nome = nome ?? state.nome,
        login = login ?? state.login,
        senha = senha ?? state.senha,
        tipo = tipo ?? state.tipo;

  UsuarioEditarEmProgresso.empty({
    this.nome,
    this.login,
    this.senha,
    this.tipo,
  });

  @override
  List<Object?> get props => [
        nome,
        login,
        senha,
        tipo,
      ];
}
