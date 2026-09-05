import 'package:comercial/domain/data/repositories/i_ecommerce_repository.dart';
import 'package:comercial/models.dart';

class PublicarReferenciasEmLoteEcommerce {
  final IEcommerceRepository _repository;

  PublicarReferenciasEmLoteEcommerce({required IEcommerceRepository repository})
      : _repository = repository;

  Future<EcommerceLoteResultado> call(
    int ecommerceId, {
    required List<int> ids,
    required bool rascunho,
    void Function(int atual, int total)? onProgresso,
  }) {
    return _repository.publicarReferenciasEmLote(
      ecommerceId,
      ids: ids,
      rascunho: rascunho,
      onProgresso: onProgresso,
    );
  }
}
