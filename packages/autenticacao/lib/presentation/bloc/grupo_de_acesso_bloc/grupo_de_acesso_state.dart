part of 'grupo_de_acesso_bloc.dart';

abstract class GrupoDeAcessoState extends Equatable {
  GrupoDeAcesso? get grupoDeAcesso => null;
  List<Permissao>? get permissoesNaoUtilizadasNoGrupo => null;
  List<Permissao>? get permissoesDoGrupo => null;

  String? get nome => null;
  int? get id => null;

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
  @override
  final String nome;
  @override
  final int? id;
  @override
  final GrupoDeAcesso? grupoDeAcesso;
  @override
  final List<Permissao>? permissoesNaoUtilizadasNoGrupo;
  @override
  final List<Permissao>? permissoesDoGrupo;

  const GrupoDeAcessoEdicaoEmProgresso({
    required this.nome,
    this.id,
    this.grupoDeAcesso,
    this.permissoesNaoUtilizadasNoGrupo,
    this.permissoesDoGrupo,
  });

  factory GrupoDeAcessoEdicaoEmProgresso.fromLastState(
    GrupoDeAcessoState state, {
    String? nome,
    int? id,
    GrupoDeAcesso? grupoDeAcesso,
    List<Permissao>? permissoesNaoUtilizadasNoGrupo,
    List<Permissao>? permissoesDoGrupo,
    List<Permissao>? permissoesRemovidas,
  }) {
    return GrupoDeAcessoEdicaoEmProgresso(
      nome: (nome ?? state.nome) ?? '',
      id: id ?? state.id,
      grupoDeAcesso: grupoDeAcesso ?? state.grupoDeAcesso,
      permissoesNaoUtilizadasNoGrupo: permissoesNaoUtilizadasNoGrupo ??
          state.permissoesNaoUtilizadasNoGrupo,
      permissoesDoGrupo: permissoesDoGrupo ?? state.permissoesDoGrupo,
    );
  }
  GrupoDeAcessoEdicaoEmProgresso copyWith({
    String? nome,
    int? id,
    GrupoDeAcesso? grupoDeAcesso,
    List<Permissao>? permissoesNaoUtilizadasNoGrupo,
    List<Permissao>? permissoesDoGrupo,
    List<Permissao>? permissoesRemovidas,
  }) {
    return GrupoDeAcessoEdicaoEmProgresso(
      nome: nome ?? this.nome,
      id: id ?? this.id,
      grupoDeAcesso: grupoDeAcesso ?? this.grupoDeAcesso,
      permissoesNaoUtilizadasNoGrupo:
          permissoesNaoUtilizadasNoGrupo ?? this.permissoesNaoUtilizadasNoGrupo,
      permissoesDoGrupo: permissoesDoGrupo ?? this.permissoesDoGrupo,
    );
  }

  @override
  List<Object?> get props => [
        nome,
        id,
        permissoesNaoUtilizadasNoGrupo,
        grupoDeAcesso,
        permissoesDoGrupo,
      ];
}

class GrupoDeAcessoSalvarEmProgresso extends GrupoDeAcessoState {}

class GrupoDeAcessoSalvarSucesso extends GrupoDeAcessoState {
  @override
  final GrupoDeAcesso grupoDeAcesso;
  @override
  final List<Permissao>? permissoesNaoUtilizadasNoGrupo;
  @override
  final List<Permissao>? permissoesDoGrupo;

  const GrupoDeAcessoSalvarSucesso({
    required this.grupoDeAcesso,
    required this.permissoesDoGrupo,
    required this.permissoesNaoUtilizadasNoGrupo,
  });
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

class GrupoDeAcessoExcluirGrupoEmProgresso extends GrupoDeAcessoState {}

class GrupoDeAcessoExcluirGrupoSucesso extends GrupoDeAcessoState {}

class GrupoDeAcessoExcluirGrupoFalha extends GrupoDeAcessoState {}
