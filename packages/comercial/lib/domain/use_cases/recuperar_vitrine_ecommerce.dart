import 'package:comercial/domain/data/repositories/i_ecommerce_vitrine_repository.dart';
import 'package:comercial/domain/models/ecommerce_vitrine.dart';

class RecuperarVitrineEcommerce {
  final IEcommerceVitrineRepository _repository;

  RecuperarVitrineEcommerce({required IEcommerceVitrineRepository repository})
      : _repository = repository;

  Future<EcommerceVitrine> call(int ecommerceId) => _repository.recuperar(ecommerceId);
}
