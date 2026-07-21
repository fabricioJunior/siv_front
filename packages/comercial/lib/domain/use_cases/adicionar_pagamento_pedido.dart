import 'package:comercial/domain/data/repositories/i_pedidos_repository.dart';
import 'package:comercial/domain/models/pedido_pagamento.dart';

class AdicionarPagamentoPedido {
  final IPedidosRepository _repository;

  AdicionarPagamentoPedido({required IPedidosRepository repository})
      : _repository = repository;

  Future<PedidoPagamento> call(
    int id, {
    required int formaDePagamentoId,
    required double valorEsperado,
    double? taxaAplicada,
  }) {
    return _repository.adicionarPagamento(
      id,
      formaDePagamentoId: formaDePagamentoId,
      valorEsperado: valorEsperado,
      taxaAplicada: taxaAplicada,
    );
  }
}
