import 'package:comercial/domain/data/repositories/i_ecommerce_repository.dart';
import 'package:comercial/models.dart';

class RecuperarProdutosDaReferenciaEcommerce {
  final IEcommerceRepository _repository;

  RecuperarProdutosDaReferenciaEcommerce({
    required IEcommerceRepository repository,
  }) : _repository = repository;

  Future<List<EcommerceReferenciaProduto>> call(
    int ecommerceId,
    int referenciaId,
  ) {
    return _repository.recuperarProdutosDaReferencia(
      ecommerceId,
      referenciaId,
    );
  }
}
