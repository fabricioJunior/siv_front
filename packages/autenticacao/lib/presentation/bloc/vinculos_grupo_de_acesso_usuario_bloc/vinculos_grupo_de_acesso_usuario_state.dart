part of 'vinculos_grupo_de_acesso_usuario_bloc.dart';

abstract class VinculosGrupoDeAcessoUsuarioState extends Equatable {
  List<VinculoGrupoDeAcessoEUsuario> get vinculos => [];
  int? get idUsuario => null;
  List<Empresa> get empresas => [];

  @override
  List<Object?> get props => [vinculos, idUsuario];
}

class VinculosGrupoDeAcessoUsuarioInitial
    extends VinculosGrupoDeAcessoUsuarioState {}

class VinculosGrupoDeAcessoUsuarioCarregarEmProgresso
    extends VinculosGrupoDeAcessoUsuarioState {
  @override
  final int? idUsuario;

  VinculosGrupoDeAcessoUsuarioCarregarEmProgresso({required this.idUsuario});
}

class VinculosGrupoDeAcessoUsuarioCarregarSucesso
    extends VinculosGrupoDeAcessoUsuarioState {
  @override
  final List<VinculoGrupoDeAcessoEUsuario> vinculos;
  @override
  final int? idUsuario;

  @override
  final List<Empresa> empresas;

  VinculosGrupoDeAcessoUsuarioCarregarSucesso({
    required this.vinculos,
    required this.idUsuario,
    required this.empresas,
  });
}

class VinculosGrupoDeAcessoUsuarioCarregarFalha
    extends VinculosGrupoDeAcessoUsuarioState {
  @override
  final int? idUsuario;

  VinculosGrupoDeAcessoUsuarioCarregarFalha({required this.idUsuario});
}

class VinculosGrupoDeAcessoUsuarioVincularEmProgresso
    extends VinculosGrupoDeAcessoUsuarioState {
  @override
  final int? idUsuario;

  VinculosGrupoDeAcessoUsuarioVincularEmProgresso({required this.idUsuario});
}

class VinculosGrupoDeAcessoUsuarioVincularSucesso
    extends VinculosGrupoDeAcessoUsuarioState {
  @override
  final List<VinculoGrupoDeAcessoEUsuario> vinculos;
  @override
  final int? idUsuario;

  VinculosGrupoDeAcessoUsuarioVincularSucesso({
    required this.vinculos,
    required this.idUsuario,
  });
}

class VinculosGrupoDeAcessoUsuarioVincularFalha
    extends VinculosGrupoDeAcessoUsuarioState {
  @override
  final int? idUsuario;

  VinculosGrupoDeAcessoUsuarioVincularFalha({required this.idUsuario});
}
