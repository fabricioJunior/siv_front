import 'dart:typed_data';

import 'package:comercial/domain/models/ecommerce_banner.dart';

abstract class IEcommerceBannersRemoteDataSource {
  Future<List<EcommerceBanner>> recuperarBanners(int ecommerceId);

  Future<EcommerceBanner> criarBanner(
    int ecommerceId, {
    required Uint8List bytes,
    required String nomeArquivo,
    void Function(int enviado, int total)? onProgresso,
  });

  Future<void> atualizarBanner(
    int ecommerceId,
    int id, {
    int? ordem,
    bool? ativo,
  });

  Future<void> excluirBanner(int ecommerceId, int id);
}
