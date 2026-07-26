import 'package:comercial/domain/data/repositories/i_pedidos_repository.dart';
import 'package:comercial/models.dart';

class ConfirmarRetiradaLotePedido {
  final IPedidosRepository _repository;

  ConfirmarRetiradaLotePedido({required IPedidosRepository repository})
      : _repository = repository;

  Future<List<Pedido>> call(List<int> pedidoIds) =>
      _repository.confirmarRetiradaLote(pedidoIds);
}
