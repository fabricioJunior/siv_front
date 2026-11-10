import 'package:comercial/domain/data/repositories/i_pedidos_repository.dart';
import 'package:comercial/models.dart';

class ListarRetiradaPendentesPedido {
  final IPedidosRepository _repository;

  ListarRetiradaPendentesPedido({required IPedidosRepository repository})
      : _repository = repository;

  Future<List<Pedido>> call(int id) => _repository.listarRetiradaPendentes(id);
}
