import 'package:comercial/domain/data/repositories/i_ecommerce_repository.dart';
import 'package:comercial/models.dart';

class SalvarEcommerce {
  final IEcommerceRepository _repository;

  SalvarEcommerce({required IEcommerceRepository repository})
      : _repository = repository;

  Future<Ecommerce> call(Ecommerce ecommerce) {
    if (ecommerce.id != null) {
      return _repository.atualizarEcommerce(ecommerce);
    }
    return _repository.criarEcommerce(ecommerce);
  }
}
