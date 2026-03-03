part of 'tamanho_bloc.dart';

abstract class TamanhoEvent {}

class TamanhoIniciou extends TamanhoEvent {
  final int? idTamanho;

  TamanhoIniciou({this.idTamanho});
}

class TamanhoEditou extends TamanhoEvent {
  final String nome;

  TamanhoEditou({required this.nome});
}

class TamanhoSalvou extends TamanhoEvent {}
