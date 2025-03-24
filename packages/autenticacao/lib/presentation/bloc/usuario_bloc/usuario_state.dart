part of 'usuario_bloc.dart';

abstract class UsuarioState extends Equatable {
  Usuario? get usuario;
  @override
  List<Object?> get props => [];
}

class UsuarioNaoInicializado extends UsuarioState {
  @override
  Usuario? get usuario => null;
}

class UsuarioCarregarEmProgresso extends UsuarioState {
  @override
  Usuario? get usuario => null;
}

class UsuarioCarregarSucesso extends UsuarioState {
  @override
  final Usuario usuario;

  UsuarioCarregarSucesso({required this.usuario});

  @override
  List<Object?> get props => [usuario];
}

class UsuarioCarregarFalha extends UsuarioState {
  @override
  Usuario? get usuario => null;
}

class UsuarioEditarEmProgresso extends UsuarioState {
  final String? nome;
  final String? login;
  final String? senha;
  final TipoUsuario? tipo;
  @override
  final Usuario? usuario;

  UsuarioEditarEmProgresso(this.usuario)
      : nome = usuario?.nome,
        login = usuario?.login,
        senha = usuario?.senha,
        tipo = usuario?.tipo;

  UsuarioEditarEmProgresso.fromLastState(
    UsuarioEditarEmProgresso state, {
    String? nome,
    String? login,
    String? senha,
    TipoUsuario? tipo,
    Usuario? usuario,
  })  : nome = nome ?? state.nome,
        login = login ?? state.login,
        senha = senha ?? state.senha,
        tipo = tipo ?? state.tipo,
        usuario = usuario ?? state.usuario;

  UsuarioEditarEmProgresso.empty({
    this.nome,
    this.login,
    this.senha,
    this.tipo,
    this.usuario,
  });

  @override
  List<Object?> get props => [
        nome,
        login,
        senha,
        tipo,
        usuario,
      ];
}

class UsuarioSalvarEmProgresso extends UsuarioState {
  @override
  Usuario? get usuario => null;
}

class UsuarioSalvarSucesso extends UsuarioState {
  @override
  final Usuario usuario;

  @override
  List<Object?> get props => [usuario];

  UsuarioSalvarSucesso({required this.usuario});
}

class UsuarioSalvarFalha extends UsuarioState {
  @override
  Usuario? get usuario => null;
}
