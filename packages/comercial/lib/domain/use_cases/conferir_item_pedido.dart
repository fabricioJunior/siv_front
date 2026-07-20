import 'package:comercial/domain/data/repositories/i_pedidos_repository.dart';

class ConferirItemPedido {
  final IPedidosRepository _repository;

  ConferirItemPedido({required IPedidosRepository repository})
      : _repository = repository;

  Future<void> call(
    int id, {
    required int produtoId,
    required int sequencia,
    required double quantidade,
  }) {
    return _repository.conferirItem(
      id,
      produtoId: produtoId,
      sequencia: sequencia,
      quantidade: quantidade,
    );
  }
}
