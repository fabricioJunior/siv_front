part of 'pedidos_bloc.dart';

abstract class PedidosEvent {}

class PedidosIniciou extends PedidosEvent {}

class PedidosBuscaAlterada extends PedidosEvent {
  final String busca;

  PedidosBuscaAlterada(this.busca);
}

class PedidosFiltroSituacaoAlterado extends PedidosEvent {
  final String? situacao;

  PedidosFiltroSituacaoAlterado(this.situacao);
}

class PedidosPedidoCancelou extends PedidosEvent {
  final int pedidoId;
  final String motivoCancelamento;

  PedidosPedidoCancelou(this.pedidoId, {required this.motivoCancelamento});
}
