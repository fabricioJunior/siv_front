import 'dart:typed_data';

import 'package:comercial/domain/data/repositories/i_ecommerce_banners_repository.dart';
import 'package:comercial/domain/models/ecommerce_banner.dart';

class CriarBannerEcommerce {
  final IEcommerceBannersRepository _repository;

  CriarBannerEcommerce({required IEcommerceBannersRepository repository})
      : _repository = repository;

  Future<EcommerceBanner> call(
    int ecommerceId, {
    required Uint8List bytes,
    required String nomeArquivo,
    void Function(int enviado, int total)? onProgresso,
  }) =>
      _repository.criarBanner(
        ecommerceId,
        bytes: bytes,
        nomeArquivo: nomeArquivo,
        onProgresso: onProgresso,
      );
}
