import 'package:comercial/domain/data/repositories/i_pedidos_repository.dart';

class EmbalarPedido {
  final IPedidosRepository _repository;

  EmbalarPedido({required IPedidosRepository repository})
      : _repository = repository;

  Future<void> call(int id) => _repository.embalarPedido(id);
}
