part of 'precos_da_referencia_bloc.dart';

abstract class PrecosDaReferenciaEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class PrecosDaReferenciaIniciou extends PrecosDaReferenciaEvent {
  final int referenciaId;
  PrecosDaReferenciaIniciou({required this.referenciaId});
  @override
  List<Object?> get props => [referenciaId];
}

class PrecosDaReferenciaEditouLinha extends PrecosDaReferenciaEvent {
  final int tabelaDePrecoId;
  PrecosDaReferenciaEditouLinha({required this.tabelaDePrecoId});
  @override
  List<Object?> get props => [tabelaDePrecoId];
}

class PrecosDaReferenciaValorAlterou extends PrecosDaReferenciaEvent {
  final String texto;
  PrecosDaReferenciaValorAlterou({required this.texto});
  @override
  List<Object?> get props => [texto];
}

class PrecosDaReferenciaCancelouEdicao extends PrecosDaReferenciaEvent {}

class PrecosDaReferenciaSalvou extends PrecosDaReferenciaEvent {}
