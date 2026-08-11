import 'package:comercial/domain/data/repositories/i_pedidos_repository.dart';

class ConferirItemPedidoPorCodigo {
  final IPedidosRepository _repository;

  ConferirItemPedidoPorCodigo({required IPedidosRepository repository})
      : _repository = repository;

  Future<void> call(
    int id, {
    required String codigoBarras,
    required double quantidade,
  }) {
    return _repository.conferirItemPorCodigo(
      id,
      codigoBarras: codigoBarras,
      quantidade: quantidade,
    );
  }
}
