enum EcommerceBannerTipo { imagem, video }

enum EcommerceBannerDispositivo { desktop, mobile }

class EcommerceBanner {
  final int id;
  final int ecommerceId;
  final EcommerceBannerTipo type;
  final EcommerceBannerDispositivo dispositivo;
  final String url;
  final int ordem;
  final bool ativo;

  const EcommerceBanner({
    required this.id,
    required this.ecommerceId,
    required this.type,
    required this.dispositivo,
    required this.url,
    required this.ordem,
    required this.ativo,
  });

  EcommerceBanner copyWith({int? ordem, bool? ativo}) => EcommerceBanner(
        id: id,
        ecommerceId: ecommerceId,
        type: type,
        dispositivo: dispositivo,
        url: url,
        ordem: ordem ?? this.ordem,
        ativo: ativo ?? this.ativo,
      );
}
