import 'package:comercial/domain/data/repositories/i_pedidos_repository.dart';

class ReenviarEmailEmbaladoPedido {
  final IPedidosRepository _repository;

  ReenviarEmailEmbaladoPedido({required IPedidosRepository repository})
      : _repository = repository;

  Future<void> call(int id) => _repository.reenviarEmailEmbalado(id);
}
