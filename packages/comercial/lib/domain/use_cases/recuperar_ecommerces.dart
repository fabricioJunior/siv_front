import 'package:comercial/domain/data/repositories/i_ecommerce_repository.dart';
import 'package:comercial/models.dart';

class RecuperarEcommerces {
  final IEcommerceRepository _repository;

  RecuperarEcommerces({required IEcommerceRepository repository})
      : _repository = repository;

  Future<List<Ecommerce>> call() => _repository.recuperarEcommerces();
}
