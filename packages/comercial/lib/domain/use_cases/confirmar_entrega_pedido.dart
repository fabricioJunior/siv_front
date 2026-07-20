import 'package:comercial/domain/data/repositories/i_pedidos_repository.dart';

class ConfirmarEntregaPedido {
  final IPedidosRepository _repository;

  ConfirmarEntregaPedido({required IPedidosRepository repository})
      : _repository = repository;

  Future<void> call(int id) => _repository.confirmarEntrega(id);
}
