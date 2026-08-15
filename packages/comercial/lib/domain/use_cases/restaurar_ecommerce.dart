import 'package:comercial/domain/data/repositories/i_ecommerce_repository.dart';

class RestaurarEcommerce {
  final IEcommerceRepository _repository;

  RestaurarEcommerce({required IEcommerceRepository repository})
      : _repository = repository;

  Future<void> call(int id) => _repository.restaurarEcommerce(id);
}
