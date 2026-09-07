import 'package:comercial/domain/data/repositories/i_ecommerce_banners_repository.dart';
import 'package:comercial/domain/models/ecommerce_banner.dart';

class RecuperarBannersEcommerce {
  final IEcommerceBannersRepository _repository;

  RecuperarBannersEcommerce({required IEcommerceBannersRepository repository})
      : _repository = repository;

  Future<List<EcommerceBanner>> call(int ecommerceId) =>
      _repository.recuperarBanners(ecommerceId);
}
