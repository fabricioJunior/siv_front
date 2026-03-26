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

class PrecoDaTabelaCriarSolicitado extends PrecosDaTabelaEvent {
  final int referenciaId;
  final double valor;

  PrecoDaTabelaCriarSolicitado({
    required this.referenciaId,
    required this.valor,
  });

  @override
  List<Object?> get props => [referenciaId, valor];
}

class PrecoDaTabelaAtualizarSolicitado extends PrecosDaTabelaEvent {
  final int referenciaId;
  final double valor;

  PrecoDaTabelaAtualizarSolicitado({
    required this.referenciaId,
    required this.valor,
  });

  @override
  List<Object?> get props => [referenciaId, valor];
}

class PrecoDaTabelaRemoverSolicitado extends PrecosDaTabelaEvent {
  final int referenciaId;

  PrecoDaTabelaRemoverSolicitado({required this.referenciaId});

  @override
  List<Object?> get props => [referenciaId];
}
