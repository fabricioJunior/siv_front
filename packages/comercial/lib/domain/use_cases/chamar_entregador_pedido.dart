import 'package:comercial/domain/data/repositories/i_pedidos_repository.dart';

class ChamarEntregadorPedido {
  final IPedidosRepository _repository;

  ChamarEntregadorPedido({required IPedidosRepository repository})
      : _repository = repository;

  Future<void> call(int id) => _repository.chamarEntregador(id);
}
