import 'package:comercial/domain/data/repositories/i_pedidos_repository.dart';

class FaturarPedido {
  final IPedidosRepository _repository;

  FaturarPedido({
    required IPedidosRepository repository,
  }) : _repository = repository;

  Future<void> call(int id, {required int caixaId}) =>
      _repository.faturarPedido(id, caixaId: caixaId);
}
