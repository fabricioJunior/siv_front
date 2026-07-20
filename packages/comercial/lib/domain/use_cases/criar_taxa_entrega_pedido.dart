import 'package:comercial/domain/data/repositories/i_pedidos_repository.dart';
import 'package:comercial/domain/models/pedido.dart';

class CriarTaxaEntregaPedido {
  final IPedidosRepository _repository;

  CriarTaxaEntregaPedido({required IPedidosRepository repository})
      : _repository = repository;

  Future<Pedido> call(
    int id, {
    required double valorTaxaEntrega,
    required int enderecoEntregaId,
  }) {
    return _repository.criarTaxaEntrega(
      id,
      valorTaxaEntrega: valorTaxaEntrega,
      enderecoEntregaId: enderecoEntregaId,
    );
  }
}
