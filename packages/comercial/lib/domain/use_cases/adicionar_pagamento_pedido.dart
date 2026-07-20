import 'package:comercial/domain/data/repositories/i_pedidos_repository.dart';
import 'package:comercial/domain/models/pedido_pagamento.dart';

class AdicionarPagamentoPedido {
  final IPedidosRepository _repository;

  AdicionarPagamentoPedido({required IPedidosRepository repository})
      : _repository = repository;

  Future<PedidoPagamento> call(
    int id, {
    required String tipo,
    int? pagamentoAvulsoId,
    String? formaPagamento,
    required double valorEsperado,
  }) {
    return _repository.adicionarPagamento(
      id,
      tipo: tipo,
      pagamentoAvulsoId: pagamentoAvulsoId,
      formaPagamento: formaPagamento,
      valorEsperado: valorEsperado,
    );
  }
}
