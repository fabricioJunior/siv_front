import 'package:comercial/domain/data/repositories/i_pedidos_repository.dart';

class CancelarPedido {
  final IPedidosRepository _repository;

  CancelarPedido({
    required IPedidosRepository repository,
  }) : _repository = repository;

  Future<void> call(int id, {required String motivoCancelamento}) {
    return _repository.cancelarPedido(
      id,
      motivoCancelamento: motivoCancelamento,
    );
  }
}
