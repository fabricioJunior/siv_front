part of 'permissoes_bloc.dart';

abstract class PermissoesEvent extends Equatable {
  const PermissoesEvent();

  @override
  List<Object?> get props => [];
}

class PermissoesIniciou extends PermissoesEvent {}

class PermissoesSelecionou extends PermissoesEvent {
  final Permissao permissao;

  const PermissoesSelecionou({required this.permissao});

  @override
  List<Object?> get props => [permissao];
}

class PermissoesDesselecionou extends PermissoesEvent {
  final Permissao permissao;

  const PermissoesDesselecionou({required this.permissao});

  @override
  List<Object?> get props => [permissao];
}
