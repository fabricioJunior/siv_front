part of 'pessoas_bloc.dart';

abstract class PessoasEvent {}

class PessoasIniciou extends PessoasEvent {
  final String? busca;
  final int? idPessoaSelecionada;
  PessoasIniciou({this.busca, this.idPessoaSelecionada});
}
