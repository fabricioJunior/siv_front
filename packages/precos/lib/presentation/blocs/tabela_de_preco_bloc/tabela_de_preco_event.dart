part of 'tabela_de_preco_bloc.dart';

abstract class TabelaDePrecoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class TabelaDePrecoIniciou extends TabelaDePrecoEvent {
  final int? idTabelaDePreco;

  TabelaDePrecoIniciou({this.idTabelaDePreco});

  @override
  List<Object?> get props => [idTabelaDePreco];
}

class TabelaDePrecoEditou extends TabelaDePrecoEvent {
  final String nome;
  final double? terminador;

  TabelaDePrecoEditou({required this.nome, this.terminador});

  @override
  List<Object?> get props => [nome, terminador];
}

class TabelaDePreceSalvou extends TabelaDePrecoEvent {
  TabelaDePreceSalvou();

  @override
  List<Object?> get props => [];
}
