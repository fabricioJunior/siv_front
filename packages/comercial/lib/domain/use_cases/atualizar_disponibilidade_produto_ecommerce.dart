import 'package:comercial/domain/data/repositories/i_ecommerce_repository.dart';

class AtualizarDisponibilidadeProdutoEcommerce {
  final IEcommerceRepository _repository;

  AtualizarDisponibilidadeProdutoEcommerce({
    required IEcommerceRepository repository,
  }) : _repository = repository;

  Future<void> call(
    int ecommerceId,
    int referenciaId,
    int produtoId, {
    required bool disponivel,
  }) {
    return _repository.atualizarDisponibilidadeProduto(
      ecommerceId,
      referenciaId,
      produtoId,
      disponivel: disponivel,
    );
  }
}
