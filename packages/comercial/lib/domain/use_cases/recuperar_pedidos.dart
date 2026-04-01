import 'package:comercial/domain/data/repositories/i_pedidos_repository.dart';
import 'package:comercial/domain/models/pedido.dart';

class RecuperarPedidos {
  final IPedidosRepository _repository;

  RecuperarPedidos({
    required IPedidosRepository repository,
  }) : _repository = repository;

  Future<List<Pedido>> call() => _repository.recuperarPedidos();
}
