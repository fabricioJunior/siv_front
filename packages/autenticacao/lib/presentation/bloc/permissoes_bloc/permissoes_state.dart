part of 'permissoes_bloc.dart';

abstract class PermissoesState extends Equatable {
  const PermissoesState();

  @override
  List<Object?> get props => [];
}

class PermissoesInicial extends PermissoesState {}

class PermissoesCarregarEmProgesso extends PermissoesState {}

class PermissoesCarregarSucesso extends PermissoesState {
  final List<Permissao> permissoes;

  const PermissoesCarregarSucesso({required this.permissoes});

  @override
  List<Object?> get props => [permissoes];
}

class PermissoesCarregarFalha extends PermissoesState {
  final String mensagem;

  const PermissoesCarregarFalha({required this.mensagem});

  @override
  List<Object?> get props => [mensagem];
}

class PermissoesSelecionarSucesso extends PermissoesState {
  final List<Permissao> permissoesSelecionadas;

  const PermissoesSelecionarSucesso({required this.permissoesSelecionadas});

  @override
  List<Object?> get props => [permissoesSelecionadas];
}
