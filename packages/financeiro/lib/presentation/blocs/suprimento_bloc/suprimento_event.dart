part of 'suprimento_bloc.dart';

abstract class SuprimentoEvent extends Equatable {
  const SuprimentoEvent();

  @override
  List<Object?> get props => [];
}

class SuprimentoIniciou extends SuprimentoEvent {
  final int caixaId;

  const SuprimentoIniciou({required this.caixaId});

  @override
  List<Object?> get props => [caixaId];
}

class SuprimentoCampoAlterado extends SuprimentoEvent {
  final String? valor;
  final String? descricao;

  const SuprimentoCampoAlterado({this.valor, this.descricao});

  @override
  List<Object?> get props => [valor, descricao];
}

class SuprimentoSalvou extends SuprimentoEvent {}
