part of 'sangria_bloc.dart';

abstract class SangriaEvent extends Equatable {
  const SangriaEvent();

  @override
  List<Object?> get props => [];
}

class SangriaIniciou extends SangriaEvent {
  final int caixaId;

  const SangriaIniciou({required this.caixaId});

  @override
  List<Object?> get props => [caixaId];
}

class SangriaCampoAlterado extends SangriaEvent {
  final String? valor;
  final String? descricao;

  const SangriaCampoAlterado({this.valor, this.descricao});

  @override
  List<Object?> get props => [valor, descricao];
}

class SangriaSalvou extends SangriaEvent {}
