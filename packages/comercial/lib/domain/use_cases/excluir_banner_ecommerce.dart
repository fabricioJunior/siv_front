import 'package:comercial/domain/data/repositories/i_ecommerce_banners_repository.dart';

class ExcluirBannerEcommerce {
  final IEcommerceBannersRepository _repository;

  ExcluirBannerEcommerce({required IEcommerceBannersRepository repository})
      : _repository = repository;

  Future<void> call(int ecommerceId, int id) =>
      _repository.excluirBanner(ecommerceId, id);
}
