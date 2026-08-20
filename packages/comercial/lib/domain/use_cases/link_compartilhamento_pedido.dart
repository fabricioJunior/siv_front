import 'package:comercial/domain/data/repositories/i_pedidos_repository.dart';

class LinkCompartilhamentoPedido {
  final IPedidosRepository _repository;

  LinkCompartilhamentoPedido({required IPedidosRepository repository})
      : _repository = repository;

  Future<String> call(int id) => _repository.linkCompartilhamento(id);
}
