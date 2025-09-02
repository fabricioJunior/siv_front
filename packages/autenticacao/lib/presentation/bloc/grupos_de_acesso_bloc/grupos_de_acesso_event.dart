part of 'grupos_de_acesso_bloc.dart';

abstract class GruposDeAcessoEvent extends Equatable {
  const GruposDeAcessoEvent();

  @override
  List<Object?> get props => [];
}

class GruposDeAcessoIniciouEvent extends GruposDeAcessoEvent {
  const GruposDeAcessoIniciouEvent();

  @override
  List<Object?> get props => [];
}

class GruposDeAcessoSelecionouEvent extends GruposDeAcessoEvent {
  final GrupoDeAcesso grupoDeAcesso;

  const GruposDeAcessoSelecionouEvent({required this.grupoDeAcesso});

  @override
  List<Object?> get props => [grupoDeAcesso];
}

class GruposDeAcessoDeselecionarEvent extends GruposDeAcessoEvent {
  final GrupoDeAcesso grupoDeAcesso;

  const GruposDeAcessoDeselecionarEvent({required this.grupoDeAcesso});

  @override
  List<Object?> get props => [grupoDeAcesso];
}
