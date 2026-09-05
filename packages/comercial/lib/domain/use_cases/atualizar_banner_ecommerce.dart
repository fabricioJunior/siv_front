import 'package:comercial/domain/data/repositories/i_ecommerce_banners_repository.dart';

class AtualizarBannerEcommerce {
  final IEcommerceBannersRepository _repository;

  AtualizarBannerEcommerce({required IEcommerceBannersRepository repository})
      : _repository = repository;

  Future<void> call(int ecommerceId, int id, {int? ordem, bool? ativo}) =>
      _repository.atualizarBanner(ecommerceId, id, ordem: ordem, ativo: ativo);
}
