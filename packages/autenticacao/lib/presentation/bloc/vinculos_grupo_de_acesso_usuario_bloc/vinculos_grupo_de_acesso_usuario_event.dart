part of 'vinculos_grupo_de_acesso_usuario_bloc.dart';

abstract class VinculosGrupoDeAcessoUsuarioEvent {}

class VinculosGrupoDeAcessoIniciou extends VinculosGrupoDeAcessoUsuarioEvent {
  final int idUsuario;

  VinculosGrupoDeAcessoIniciou({required this.idUsuario});
}

class VinculosGrupoDeAcessoVinculou extends VinculosGrupoDeAcessoUsuarioEvent {
  final int idGrupoDeAcesso;
  final int idEmpresa;

  VinculosGrupoDeAcessoVinculou({
    required this.idGrupoDeAcesso,
    required this.idEmpresa,
  });
}
