import 'package:comercial/domain/data/repositories/i_pedidos_repository.dart';
import 'package:comercial/domain/models/pedido.dart';

class CriarPedido {
  final IPedidosRepository _repository;

  CriarPedido({
    required IPedidosRepository repository,
  }) : _repository = repository;

  Future<Pedido> call(Pedido pedido) => _repository.criarPedido(pedido);
}
