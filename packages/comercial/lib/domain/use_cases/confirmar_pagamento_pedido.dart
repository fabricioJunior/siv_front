import 'package:comercial/domain/data/repositories/i_pedidos_repository.dart';
import 'package:comercial/domain/models/pedido_pagamento.dart';

class ConfirmarPagamentoPedido {
  final IPedidosRepository _repository;

  ConfirmarPagamentoPedido({required IPedidosRepository repository})
      : _repository = repository;

  Future<PedidoPagamento> call(
    int id,
    int pagamentoId, {
    required double valorConfirmado,
  }) {
    return _repository.confirmarPagamento(
      id,
      pagamentoId,
      valorConfirmado: valorConfirmado,
    );
  }
}
