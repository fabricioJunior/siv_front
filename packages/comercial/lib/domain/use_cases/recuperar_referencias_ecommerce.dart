import 'package:comercial/domain/data/repositories/i_ecommerce_repository.dart';
import 'package:comercial/models.dart';

class RecuperarReferenciasEcommerce {
  final IEcommerceRepository _repository;

  RecuperarReferenciasEcommerce({required IEcommerceRepository repository})
      : _repository = repository;

  Future<EcommerceReferenciasPagina> call(
    int ecommerceId, {
    String? busca,
    List<int>? categoriaIds,
    bool? rascunho,
    bool? publicavel,
    int page = 1,
    int limit = 50,
  }) {
    return _repository.recuperarReferencias(
      ecommerceId,
      busca: busca,
      categoriaIds: categoriaIds,
      rascunho: rascunho,
      publicavel: publicavel,
      page: page,
      limit: limit,
    );
  }
}
