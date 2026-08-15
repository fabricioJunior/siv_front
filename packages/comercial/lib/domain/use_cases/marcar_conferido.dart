import 'package:comercial/domain/data/repositories/i_pedidos_repository.dart';

// Conferência retroativa -- pedido de e-commerce faturado automaticamente pula direto pra
// encerrado sem passar por ConferirPedido. Não mexe em situacao, só registra a conferência física.
class MarcarConferido {
  final IPedidosRepository _repository;

  MarcarConferido({
    required IPedidosRepository repository,
  }) : _repository = repository;

  Future<void> call(int id) {
    return _repository.marcarConferido(id);
  }
}
