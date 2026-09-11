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
    );
  }
}
