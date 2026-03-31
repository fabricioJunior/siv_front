part of 'pedidos_bloc.dart';

abstract class PedidosEvent {}

class PedidosIniciou extends PedidosEvent {}

class PedidosBuscaAlterada extends PedidosEvent {
  final String busca;

  PedidosBuscaAlterada(this.busca);
}
