import 'package:comercial/domain/data/repositories/i_pedidos_repository.dart';
import 'package:comercial/models.dart';

/// Vendedor converte um pedido online (site ou agente de IA) ainda não pago em pedido de balcão.
class ConverterPedidoParaBalcao {
  final IPedidosRepository _repository;

  ConverterPedidoParaBalcao({required IPedidosRepository repository})
      : _repository = repository;

  Future<Pedido> call(int id, {required int funcionarioId}) {
    return _repository.converterParaBalcao(id, funcionarioId: funcionarioId);
  }
}
