part of 'tabelas_de_preco_bloc.dart';

abstract class TabelasDePrecoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class TabelasDePrecoIniciou extends TabelasDePrecoEvent {
  final String? busca;
  final bool? inativa;

  TabelasDePrecoIniciou({this.busca, this.inativa});

  @override
  List<Object?> get props => [busca, inativa];
}

class TabelasDePrecoDesativar extends TabelasDePrecoEvent {
  final int id;

  TabelasDePrecoDesativar({required this.id});

  @override
  List<Object?> get props => [id];
}
