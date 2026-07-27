part of 'compras_do_cliente_bloc.dart';

abstract class ComprasDoClienteEvent {}

class ComprasDoClienteCarregar extends ComprasDoClienteEvent {
  final int pessoaId;
  final int limit;

  ComprasDoClienteCarregar({required this.pessoaId, this.limit = 10});
}
