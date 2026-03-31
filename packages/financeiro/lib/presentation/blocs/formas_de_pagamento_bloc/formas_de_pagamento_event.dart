part of 'formas_de_pagamento_bloc.dart';

abstract class FormasDePagamentoEvent {}

class FormasDePagamentoIniciou extends FormasDePagamentoEvent {
  final String? busca;

  FormasDePagamentoIniciou({this.busca});
}
