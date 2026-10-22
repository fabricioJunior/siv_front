import 'package:comercial/domain/data/repositories/i_pedidos_repository.dart';
import 'package:comercial/domain/models/pedido.dart';

class AplicarDescontosPromocionaisPedido {
  final IPedidosRepository _repository;

  AplicarDescontosPromocionaisPedido({
    required IPedidosRepository repository,
  }) : _repository = repository;

  Future<Pedido> call(
    int id, {
    required List<Map<String, dynamic>> descontosPromocao,
    Map<String, dynamic>? cupom,
  }) =>
      _repository.aplicarDescontosPromocionais(
        id,
        descontosPromocao: descontosPromocao,
        cupom: cupom,
      );
}
