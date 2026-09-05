import 'dart:typed_data';

import 'package:comercial/data/remote/dtos/ecommerce_banner_dto.dart';
import 'package:comercial/domain/data/remote/i_ecommerce_banners_remote_data_source.dart';
import 'package:comercial/domain/models/ecommerce_banner.dart';
import 'package:core/remote_data_sourcers.dart';

class EcommerceBannersRemoteDataSource extends RemoteDataSourceBase
    implements IEcommerceBannersRemoteDataSource {
  EcommerceBannersRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/e-commerce/{id}';

  @override
  Future<List<EcommerceBanner>> recuperarBanners(int ecommerceId) async {
    final response = await get(
      pathParameters: {'id': '$ecommerceId/banners'},
    );
    return (response.body as List<dynamic>)
        .map((json) => EcommerceBannerDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<EcommerceBanner> criarBanner(
    int ecommerceId, {
    required Uint8List bytes,
    required String nomeArquivo,
    void Function(int enviado, int total)? onProgresso,
  }) async {
    final response = await postFile(
      field: 'file',
      bytes: bytes,
      fileName: nomeArquivo,
      fileType: _tipoPorExtensao(nomeArquivo),
      pathParameters: {'id': '$ecommerceId/banners'},
      onSendProgress: onProgresso,
    );
    return EcommerceBannerDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<void> atualizarBanner(
    int ecommerceId,
    int id, {
    int? ordem,
    bool? ativo,
  }) async {
    await put(
      pathParameters: {'id': '$ecommerceId/banners/$id'},
      body: {
        if (ordem != null) 'ordem': ordem,
        if (ativo != null) 'ativo': ativo,
      },
    );
  }

  @override
  Future<void> excluirBanner(int ecommerceId, int id) async {
    await delete(pathParameters: {'id': '$ecommerceId/banners/$id'});
  }

  FileType _tipoPorExtensao(String nomeArquivo) {
    final ext = nomeArquivo.split('.').last.toLowerCase();
    if (['mp4', 'mov', 'webm', 'avi'].contains(ext)) return FileType.video;
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) return FileType.image;
    return FileType.other;
  }
}
