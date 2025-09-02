part of 'grupo_de_acesso_bloc.dart';

abstract class GrupoDeAcessoState extends Equatable {
  GrupoDeAcesso? get grupoDeAcesso => null;
  const GrupoDeAcessoState();

  @override
  List<Object?> get props => [grupoDeAcesso];
}

class GrupoDeAcessoInitial extends GrupoDeAcessoState {}

class GrupoDeAcessoCarregarEmProgresso extends GrupoDeAcessoState {}

class GrupoDeAcessoCarregarSucesso extends GrupoDeAcessoState {}

class GrupoDeAcessoCarregarFalha extends GrupoDeAcessoState {
  final String erroMessage;

  const GrupoDeAcessoCarregarFalha({required this.erroMessage});

  @override
  GrupoDeAcesso? get grupoDeAcesso => null;
}

class GrupoDeAcessoEdicaoEmProgresso extends GrupoDeAcessoState {
  final String nome;
  final int? id;
  @override
  final GrupoDeAcesso? grupoDeAcesso;
  final List<Permissao>? permissoes;

  const GrupoDeAcessoEdicaoEmProgresso({
    required this.nome,
    this.id,
    this.grupoDeAcesso,
    this.permissoes,
  });

  GrupoDeAcessoEdicaoEmProgresso copyWith({
    String? nome,
    int? id,
    GrupoDeAcesso? grupoDeAcesso,
    List<Permissao>? permissoes,
  }) {
    return GrupoDeAcessoEdicaoEmProgresso(
      nome: nome ?? this.nome,
      id: id ?? this.id,
      grupoDeAcesso: grupoDeAcesso ?? this.grupoDeAcesso,
      permissoes: permissoes ?? this.permissoes,
    );
  }

  @override
  List<Object?> get props => [nome, id, permissoes];
}

class GrupoDeAcessoSalvarEmProgresso extends GrupoDeAcessoState {}

class GrupoDeAcessoSalvarSucesso extends GrupoDeAcessoState {
  @override
  final GrupoDeAcesso grupoDeAcesso;

  const GrupoDeAcessoSalvarSucesso({required this.grupoDeAcesso});
}

class GrupoDeAcessoSalvarFalha extends GrupoDeAcessoState {
  final String mensagem;

  const GrupoDeAcessoSalvarFalha({required this.mensagem});

  @override
  List<Object?> get props => [mensagem];
}

class GrupoDeAcessoErro extends GrupoDeAcessoState {
  final String mensagem;

  const GrupoDeAcessoErro({required this.mensagem});

  @override
  List<Object?> get props => [mensagem];
}
