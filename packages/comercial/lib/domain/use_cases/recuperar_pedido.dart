import 'package:comercial/domain/data/repositories/i_pedidos_repository.dart';
import 'package:comercial/domain/models/pedido.dart';

class RecuperarPedido {
  final IPedidosRepository _repository;

  RecuperarPedido({
    required IPedidosRepository repository,
  }) : _repository = repository;

  Future<Pedido> call(int id) => _repository.recuperarPedido(id);
}
