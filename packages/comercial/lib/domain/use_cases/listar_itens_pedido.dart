import 'package:comercial/domain/data/repositories/i_pedidos_repository.dart';
import 'package:comercial/domain/models/pedido_item.dart';

class ListarItensPedido {
  final IPedidosRepository _repository;

  ListarItensPedido({required IPedidosRepository repository})
      : _repository = repository;

  Future<List<PedidoItem>> call(int id) {
    return _repository.listarItens(id);
  }
}
