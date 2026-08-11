import 'package:comercial/domain/data/repositories/i_ecommerce_repository.dart';
import 'package:comercial/models.dart';

class RecuperarEcommerce {
  final IEcommerceRepository _repository;

  RecuperarEcommerce({required IEcommerceRepository repository})
      : _repository = repository;

  Future<Ecommerce> call(int id) => _repository.recuperarEcommerce(id);
}
