import 'package:comercial/domain/data/repositories/i_pedidos_repository.dart';
import 'package:comercial/domain/models/pedido_pagamento.dart';

class ListarPagamentosPedido {
  final IPedidosRepository _repository;

  ListarPagamentosPedido({required IPedidosRepository repository})
      : _repository = repository;

  Future<List<PedidoPagamento>> call(int id) {
    return _repository.listarPagamentos(id);
  }
}
