import 'package:comercial/domain/data/repositories/i_pedidos_repository.dart';

class RemoverItemPedido {
  final IPedidosRepository _repository;

  RemoverItemPedido({required IPedidosRepository repository})
      : _repository = repository;

  Future<void> call(
    int id, {
    required int produtoId,
    required int sequencia,
    required double quantidade,
  }) {
    return _repository.removerItem(
      id,
      produtoId: produtoId,
      sequencia: sequencia,
      quantidade: quantidade,
    );
  }
}
