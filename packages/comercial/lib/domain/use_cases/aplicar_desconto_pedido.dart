import 'package:comercial/domain/data/repositories/i_pedidos_repository.dart';
import 'package:comercial/domain/models/pedido.dart';

class AplicarDescontoPedido {
  final IPedidosRepository _repository;

  AplicarDescontoPedido({
    required IPedidosRepository repository,
  }) : _repository = repository;

  Future<Pedido> call(int id, {required double desconto}) =>
      _repository.aplicarDesconto(id, desconto: desconto);
}
