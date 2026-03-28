part of 'editar_preco_da_referencia_bloc.dart';

abstract class EditarPrecoDaReferenciaEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class EditarPrecoDaReferenciaSalvou extends EditarPrecoDaReferenciaEvent {
  final int tabelaDePrecoId;
  final int referenciaId;
  final double valor;

  EditarPrecoDaReferenciaSalvou({
    required this.tabelaDePrecoId,
    required this.referenciaId,
    required this.valor,
  });

  @override
  List<Object?> get props => [tabelaDePrecoId, referenciaId, valor];
}
