import 'package:comercial/domain/data/repositories/i_pedidos_repository.dart';
import 'package:comercial/domain/models/pedido_item.dart';

class AdicionarItemPedido {
  final IPedidosRepository _repository;

  AdicionarItemPedido({required IPedidosRepository repository})
      : _repository = repository;

  Future<PedidoItem> call(
    int id, {
    required int produtoId,
    required double quantidade,
  }) {
    return _repository.adicionarItem(
      id,
      produtoId: produtoId,
      quantidade: quantidade,
    );
  }
}
