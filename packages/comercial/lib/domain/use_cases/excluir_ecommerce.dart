import 'package:comercial/domain/data/repositories/i_ecommerce_repository.dart';

class ExcluirEcommerce {
  final IEcommerceRepository _repository;

  ExcluirEcommerce({required IEcommerceRepository repository})
      : _repository = repository;

  Future<void> call(int id) => _repository.excluirEcommerce(id);
}
