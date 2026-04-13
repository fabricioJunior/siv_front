part of 'tabelas_de_preco_bloc.dart';

abstract class TabelasDePrecoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class TabelasDePrecoIniciou extends TabelasDePrecoEvent {
  final String? busca;
  final bool? inativa;
  final int? tabelaInicialId;

  TabelasDePrecoIniciou({this.busca, this.inativa, this.tabelaInicialId});

  @override
  List<Object?> get props => [busca, inativa, tabelaInicialId];
}

class TabelasDePrecoDesativar extends TabelasDePrecoEvent {
  final int id;

  TabelasDePrecoDesativar({required this.id});

  @override
  List<Object?> get props => [id];
}
