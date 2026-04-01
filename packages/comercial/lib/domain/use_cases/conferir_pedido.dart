import 'package:comercial/domain/data/repositories/i_pedidos_repository.dart';

class ConferirPedido {
  final IPedidosRepository _repository;

  ConferirPedido({
    required IPedidosRepository repository,
  }) : _repository = repository;

  Future<void> call(int id, {bool processarComDivergencia = false}) {
    return _repository.conferirPedido(
      id,
      processarComDivergencia: processarComDivergencia,
    );
  }
}
