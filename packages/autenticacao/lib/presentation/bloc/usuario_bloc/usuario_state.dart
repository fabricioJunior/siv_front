part of 'usuario_bloc.dart';

abstract class UsuarioState extends Equatable {
  Usuario? get usuario;

  GrupoDeAcesso? get grupoDeAcesso => null;
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

  @override
  final GrupoDeAcesso? grupoDeAcesso;

  UsuarioCarregarSucesso({
    required this.usuario,
    required this.grupoDeAcesso,
  });

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
  final GrupoDeAcesso? grupoDeAcesso;
  @override
  final Usuario? usuario;

  UsuarioEditarEmProgresso(
    this.usuario, {
    GrupoDeAcesso? grupoDeAcessoDoUsuario,
  })  : nome = usuario?.nome,
        login = usuario?.login,
        senha = usuario?.senha,
        tipo = usuario?.tipo,
        grupoDeAcesso = grupoDeAcessoDoUsuario;

  UsuarioEditarEmProgresso.fromLastState(
    UsuarioEditarEmProgresso state, {
    String? nome,
    String? login,
    String? senha,
    TipoUsuario? tipo,
    Usuario? usuario,
    GrupoDeAcesso? grupoDeAcesso,
  })  : nome = nome ?? state.nome,
        login = login ?? state.login,
        senha = senha ?? state.senha,
        tipo = tipo ?? state.tipo,
        usuario = usuario ?? state.usuario,
        grupoDeAcesso = grupoDeAcesso ?? state.grupoDeAcesso;

  UsuarioEditarEmProgresso.empty({
    this.nome,
    this.login,
    this.senha,
    this.tipo,
    this.usuario,
    this.grupoDeAcesso,
  });

  @override
  List<Object?> get props => [
        nome,
        login,
        senha,
        tipo,
        usuario,
        grupoDeAcesso,
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
