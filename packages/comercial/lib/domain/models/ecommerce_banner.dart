enum EcommerceBannerTipo { imagem, video }

class EcommerceBanner {
  final int id;
  final int ecommerceId;
  final EcommerceBannerTipo type;
  final String url;
  final int ordem;
  final bool ativo;

  const EcommerceBanner({
    required this.id,
    required this.ecommerceId,
    required this.type,
    required this.url,
    required this.ordem,
    required this.ativo,
  });

  EcommerceBanner copyWith({int? ordem, bool? ativo}) => EcommerceBanner(
        id: id,
        ecommerceId: ecommerceId,
        type: type,
        url: url,
        ordem: ordem ?? this.ordem,
        ativo: ativo ?? this.ativo,
      );
}
