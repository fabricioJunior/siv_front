import 'package:comercial/domain/data/repositories/i_pedidos_repository.dart';
import 'package:comercial/models.dart';

class AssumirPedido {
  final IPedidosRepository _repository;

  AssumirPedido({required IPedidosRepository repository})
      : _repository = repository;

  Future<Pedido> call(int id, {required int funcionarioId}) {
    return _repository.assumirPedido(id, funcionarioId: funcionarioId);
  }
}
