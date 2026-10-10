import 'package:comercial/domain/models/ecommerce_banner.dart';

class EcommerceBannerDto {
  static EcommerceBanner fromJson(Map<String, dynamic> json) {
    return EcommerceBanner(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      ecommerceId: int.tryParse(json['ecommerceId']?.toString() ?? '') ?? 0,
      type: json['type']?.toString().toLowerCase() == 'video'
          ? EcommerceBannerTipo.video
          : EcommerceBannerTipo.imagem,
      dispositivo: json['dispositivo']?.toString().toLowerCase() == 'mobile'
          ? EcommerceBannerDispositivo.mobile
          : EcommerceBannerDispositivo.desktop,
      url: json['url']?.toString() ?? '',
      ordem: int.tryParse(json['ordem']?.toString() ?? '') ?? 0,
      ativo: json['ativo'] as bool? ?? true,
      link: linkDeJson(json),
    );
  }

  /// Tolerante: API antiga sem os campos novos = banner sem link. Quando
  /// `linkTipo` não vem mas o conteúdo vem, infere pelo que está preenchido.
  static EcommerceBannerLink? linkDeJson(Map<String, dynamic> json) {
    final tipo = json['linkTipo']?.toString().toLowerCase();
    final endereco = json['linkUrl']?.toString() ?? '';
    final listaId = int.tryParse(json['listaId']?.toString() ?? '');

    if (tipo == 'url' || (tipo == null && endereco.isNotEmpty)) {
      return endereco.isEmpty ? null : EcommerceBannerLink.endereco(endereco);
    }
    if (tipo == 'lista' || (tipo == null && listaId != null)) {
      return listaId == null
          ? null
          : EcommerceBannerLink.lista(
              listaId: listaId,
              listaNome: json['listaNome']?.toString(),
            );
    }
    return null;
  }

  /// Corpo do PUT parcial. `limparLink` manda `linkTipo: null` (limpa no
  /// backend); sem link e sem limpar, nada de link vai no corpo.
  static Map<String, dynamic> linkParaJson(
    EcommerceBannerLink? link, {
    bool limparLink = false,
  }) {
    if (limparLink) return {'linkTipo': null};
    if (link == null) return const {};
    if (link.tipo == EcommerceBannerLinkTipo.url) {
      return {'linkTipo': 'url', 'linkUrl': link.url};
    }
    return {'linkTipo': 'lista', 'listaId': link.listaId};
  }
}
