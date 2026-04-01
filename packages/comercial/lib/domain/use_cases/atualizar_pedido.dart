import 'package:comercial/domain/data/repositories/i_pedidos_repository.dart';
import 'package:comercial/domain/models/pedido.dart';

class AtualizarPedido {
  final IPedidosRepository _repository;

  AtualizarPedido({
    required IPedidosRepository repository,
  }) : _repository = repository;

  Future<Pedido> call(Pedido pedido) => _repository.atualizarPedido(pedido);
}
