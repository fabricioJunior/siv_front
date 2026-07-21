import 'package:comercial/domain/data/repositories/i_pedidos_repository.dart';

class RemoverPagamentoPedido {
  final IPedidosRepository _repository;

  RemoverPagamentoPedido({required IPedidosRepository repository})
      : _repository = repository;

  Future<void> call(int id, int pagamentoId) {
    return _repository.removerPagamento(id, pagamentoId);
  }
}
