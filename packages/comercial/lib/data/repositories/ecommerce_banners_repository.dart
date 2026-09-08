import 'dart:typed_data';

import 'package:comercial/domain/data/remote/i_ecommerce_banners_remote_data_source.dart';
import 'package:comercial/domain/data/repositories/i_ecommerce_banners_repository.dart';
import 'package:comercial/domain/models/ecommerce_banner.dart';

class EcommerceBannersRepository implements IEcommerceBannersRepository {
  final IEcommerceBannersRemoteDataSource remoteDataSource;

  EcommerceBannersRepository({required this.remoteDataSource});

  @override
  Future<List<EcommerceBanner>> recuperarBanners(int ecommerceId) =>
      remoteDataSource.recuperarBanners(ecommerceId);

  @override
  Future<EcommerceBanner> criarBanner(
    int ecommerceId, {
    required Uint8List bytes,
    required String nomeArquivo,
    void Function(int enviado, int total)? onProgresso,
  }) =>
      remoteDataSource.criarBanner(
        ecommerceId,
        bytes: bytes,
        nomeArquivo: nomeArquivo,
        onProgresso: onProgresso,
      );

  @override
  Future<void> atualizarBanner(
    int ecommerceId,
    int id, {
    int? ordem,
    bool? ativo,
  }) =>
      remoteDataSource.atualizarBanner(ecommerceId, id, ordem: ordem, ativo: ativo);

  @override
  Future<void> excluirBanner(int ecommerceId, int id) =>
      remoteDataSource.excluirBanner(ecommerceId, id);
}
