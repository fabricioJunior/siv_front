import 'package:comercial/domain/data/repositories/i_ecommerce_repository.dart';
import 'package:comercial/models.dart';

class AdicionarReferenciaEcommerce {
  final IEcommerceRepository _repository;

  AdicionarReferenciaEcommerce({required IEcommerceRepository repository})
      : _repository = repository;

  Future<EcommerceReferencia> call(
    int ecommerceId, {
    required int referenciaId,
    int? tabelaDePrecoId,
  }) {
    return _repository.adicionarReferencia(
      ecommerceId,
      referenciaId: referenciaId,
      tabelaDePrecoId: tabelaDePrecoId,
    );
  }
}
