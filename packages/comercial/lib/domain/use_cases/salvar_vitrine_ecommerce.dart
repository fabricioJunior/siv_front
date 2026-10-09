import 'package:comercial/domain/data/repositories/i_ecommerce_vitrine_repository.dart';
import 'package:comercial/domain/models/ecommerce_vitrine.dart';

class SalvarVitrineEcommerce {
  final IEcommerceVitrineRepository _repository;

  SalvarVitrineEcommerce({required IEcommerceVitrineRepository repository})
      : _repository = repository;

  Future<void> call(
    int ecommerceId,
    VitrineLocal local,
    List<EcommerceVitrineItem> itens,
  ) =>
      _repository.salvar(ecommerceId, local, itens);
}
