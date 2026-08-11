import 'package:comercial/domain/data/repositories/i_ecommerce_repository.dart';
import 'package:comercial/models.dart';

class AtualizarReferenciaEcommerce {
  final IEcommerceRepository _repository;

  AtualizarReferenciaEcommerce({required IEcommerceRepository repository})
      : _repository = repository;

  Future<EcommerceReferencia> call(
    int ecommerceId,
    int id, {
    bool? rascunho,
    int? tabelaDePrecoId,
  }) {
    return _repository.atualizarReferencia(
      ecommerceId,
      id,
      rascunho: rascunho,
      tabelaDePrecoId: tabelaDePrecoId,
    );
  }
}
