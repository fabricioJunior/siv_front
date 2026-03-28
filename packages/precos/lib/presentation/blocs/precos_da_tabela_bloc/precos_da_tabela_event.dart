part of 'precos_da_tabela_bloc.dart';

abstract class PrecosDaTabelaEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class PrecosDaTabelaIniciou extends PrecosDaTabelaEvent {
  final int tabelaDePrecoId;

  PrecosDaTabelaIniciou({required this.tabelaDePrecoId});

  @override
  List<Object?> get props => [tabelaDePrecoId];
}

class PrecoDaTabelaRemoverSolicitado extends PrecosDaTabelaEvent {
  final int referenciaId;

  PrecoDaTabelaRemoverSolicitado({required this.referenciaId});

  @override
  List<Object?> get props => [referenciaId];
}
