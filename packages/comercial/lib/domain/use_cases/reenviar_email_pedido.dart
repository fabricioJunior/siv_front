import 'package:comercial/domain/data/repositories/i_pedidos_repository.dart';

class ReenviarEmailPedido {
  final IPedidosRepository _repository;

  ReenviarEmailPedido({required IPedidosRepository repository})
      : _repository = repository;

  Future<void> call(int id) => _repository.reenviarEmail(id);
}
