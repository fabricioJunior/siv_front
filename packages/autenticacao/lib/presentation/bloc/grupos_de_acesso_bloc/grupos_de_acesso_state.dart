part of 'grupos_de_acesso_bloc.dart';

abstract class GruposDeAcessoState extends Equatable {
  const GruposDeAcessoState();

  @override
  List<Object?> get props => [];
}

class GruposDeAcessoInitial extends GruposDeAcessoState {}

class GruposDeAcessoCarregarEmProgresso extends GruposDeAcessoState {}

class GruposDeAcessoCarregarSucesso extends GruposDeAcessoState {
  final List<GrupoDeAcesso> grupos;
  final List<GrupoDeAcesso> gruposSelecionados;

  const GruposDeAcessoCarregarSucesso({
    required this.grupos,
    required this.gruposSelecionados,
  });

  GruposDeAcessoCarregarSucesso copyWith({
    List<GrupoDeAcesso>? grupos,
    List<GrupoDeAcesso>? gruposSelecionados,
  }) {
    return GruposDeAcessoCarregarSucesso(
      grupos: grupos ?? this.grupos,
      gruposSelecionados: gruposSelecionados ?? this.gruposSelecionados,
    );
  }

  @override
  List<Object?> get props => [grupos, gruposSelecionados];
}

class GruposDeAcessoCarregarError extends GruposDeAcessoState {
  final String mensagem;

  const GruposDeAcessoCarregarError({required this.mensagem});

  @override
  List<Object?> get props => [mensagem];
}
