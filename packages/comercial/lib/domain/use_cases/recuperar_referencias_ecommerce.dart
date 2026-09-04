import 'package:comercial/domain/data/repositories/i_ecommerce_repository.dart';
import 'package:comercial/models.dart';

class RecuperarReferenciasEcommerce {
  final IEcommerceRepository _repository;

  RecuperarReferenciasEcommerce({required IEcommerceRepository repository})
      : _repository = repository;

  Future<List<EcommerceReferencia>> call(
    int ecommerceId, {
    String? busca,
    List<int>? categoriaIds,
    bool? rascunho,
  }) {
    return _repository.recuperarReferencias(
      ecommerceId,
      busca: busca,
      categoriaIds: categoriaIds,
      rascunho: rascunho,
    );
  }
}
