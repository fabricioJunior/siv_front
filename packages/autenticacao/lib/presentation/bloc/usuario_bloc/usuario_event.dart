part of 'usuario_bloc.dart';

abstract class UsuarioEvent {}

class UsuarioIniciou extends UsuarioEvent {
  final int? idUsuario;

  UsuarioIniciou({this.idUsuario});
}

class UsuarioEditou extends UsuarioEvent {
  final String? nome;
  final String? login;
  final String? senha;
  final TipoUsuario? tipo;
  final bool? ativo;
  final GrupoDeAcesso? grupoDeAcesso;

  UsuarioEditou({
    this.nome,
    this.login,
    this.senha,
    this.tipo,
    this.ativo,
    this.grupoDeAcesso,
  });
}

class UsuarioSalvou extends UsuarioEvent {}
