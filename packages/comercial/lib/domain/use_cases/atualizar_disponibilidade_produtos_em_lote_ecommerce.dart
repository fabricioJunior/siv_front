import 'package:comercial/domain/data/repositories/i_ecommerce_repository.dart';

class AtualizarDisponibilidadeProdutosEmLoteEcommerce {
  final IEcommerceRepository _repository;

  AtualizarDisponibilidadeProdutosEmLoteEcommerce({
    required IEcommerceRepository repository,
  }) : _repository = repository;

  Future<void> call(
    int ecommerceId,
    int referenciaId, {
    required List<int> produtoIds,
    required bool disponivel,
    void Function(int atual, int total)? onProgresso,
  }) {
    return _repository.atualizarDisponibilidadeProdutosEmLote(
      ecommerceId,
      referenciaId,
      produtoIds: produtoIds,
      disponivel: disponivel,
      onProgresso: onProgresso,
    );
  }
}
