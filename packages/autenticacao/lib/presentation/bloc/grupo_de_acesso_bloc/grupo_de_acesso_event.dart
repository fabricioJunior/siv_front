part of 'grupo_de_acesso_bloc.dart';

abstract class GrupoDeAcessoEvent extends Equatable {
  const GrupoDeAcessoEvent();

  @override
  List<Object?> get props => [];
}

class GrupoDeAcessoIniciouEvent extends GrupoDeAcessoEvent {
  final int? idGrupoDeAcesso;
  final String? nome;

  const GrupoDeAcessoIniciouEvent({this.idGrupoDeAcesso, this.nome});

  @override
  List<Object?> get props => [idGrupoDeAcesso, nome];
}

class GrupoDeAcessoAlterouNomeEvent extends GrupoDeAcessoEvent {
  final String nome;

  const GrupoDeAcessoAlterouNomeEvent({required this.nome});

  @override
  List<Object?> get props => [nome];
}

class GrupoDeAcessoAdionouPermissao extends GrupoDeAcessoEvent {
  final Permissao permissao;

  const GrupoDeAcessoAdionouPermissao({required this.permissao});
}

class GrupoDeAcessoRemoveuPermissao extends GrupoDeAcessoEvent {
  final Permissao permissao;

  const GrupoDeAcessoRemoveuPermissao({required this.permissao});
}

class GrupoDeAcessoSalvou extends GrupoDeAcessoEvent {}

class GrupoExcluiu extends GrupoDeAcessoEvent {}
