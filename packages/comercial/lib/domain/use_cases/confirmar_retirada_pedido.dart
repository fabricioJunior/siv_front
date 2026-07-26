import 'package:comercial/domain/data/repositories/i_pedidos_repository.dart';
import 'package:comercial/models.dart';

class ConfirmarRetiradaPedido {
  final IPedidosRepository _repository;

  ConfirmarRetiradaPedido({required IPedidosRepository repository})
      : _repository = repository;

  Future<(Pedido, List<Pedido>)> call(int id, String codigo) =>
      _repository.confirmarRetirada(id, codigo);
}
