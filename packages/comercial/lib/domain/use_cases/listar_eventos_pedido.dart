import 'package:comercial/domain/data/repositories/i_pedidos_repository.dart';
import 'package:comercial/domain/models/pedido_evento.dart';

class ListarEventosPedido {
  final IPedidosRepository _repository;

  ListarEventosPedido({required IPedidosRepository repository})
      : _repository = repository;

  Future<List<PedidoEvento>> call(int id) => _repository.listarEventos(id);
}
