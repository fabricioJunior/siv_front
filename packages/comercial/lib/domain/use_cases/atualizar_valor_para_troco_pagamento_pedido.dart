import 'package:comercial/domain/data/repositories/i_pedidos_repository.dart';
import 'package:comercial/domain/models/pedido_pagamento.dart';

class AtualizarValorParaTrocoPagamentoPedido {
  final IPedidosRepository _repository;

  AtualizarValorParaTrocoPagamentoPedido({required IPedidosRepository repository})
      : _repository = repository;

  Future<PedidoPagamento> call(
    int id,
    int pagamentoId, {
    required double valorParaTroco,
  }) {
    return _repository.atualizarValorParaTrocoPagamento(
      id,
      pagamentoId,
      valorParaTroco: valorParaTroco,
    );
  }
}
