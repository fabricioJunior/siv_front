enum EcommerceBannerTipo { imagem, video }

enum EcommerceBannerDispositivo { desktop, mobile }

enum EcommerceBannerLinkTipo { url, lista }

/// Destino do clique no banner: um endereço digitado ou uma lista do catálogo.
class EcommerceBannerLink {
  final EcommerceBannerLinkTipo tipo;
  final String? url;
  final int? listaId;

  /// Só vem do backend (`listaNome`) para exibição -- nunca é enviado de volta.
  final String? listaNome;

  const EcommerceBannerLink.endereco(String this.url)
      : tipo = EcommerceBannerLinkTipo.url,
        listaId = null,
        listaNome = null;

  const EcommerceBannerLink.lista({required int this.listaId, this.listaNome})
      : tipo = EcommerceBannerLinkTipo.lista,
        url = null;

  /// Texto legível do destino, pro card e pra edição.
  String get rotulo => tipo == EcommerceBannerLinkTipo.url
      ? (url ?? '')
      : (listaNome?.isNotEmpty == true ? listaNome! : 'Lista #$listaId');
}

/// Valida o endereço digitado: externo (`http://`/`https://`) ou caminho
/// interno do site (`/promocoes`). Retorna `null` quando está válido.
String? validarEnderecoDoBanner(String? valor) {
  final endereco = valor?.trim() ?? '';
  if (endereco.isEmpty) return 'Informe o endereço de destino';
  final valido = endereco.startsWith('http://') ||
      endereco.startsWith('https://') ||
      endereco.startsWith('/');
  if (!valido) return 'Use https://... ou um caminho do site começando com /';
  return null;
}

class EcommerceBanner {
  final int id;
  final int ecommerceId;
  final EcommerceBannerTipo type;
  final EcommerceBannerDispositivo dispositivo;
  final String url;
  final int ordem;
  final bool ativo;
  final EcommerceBannerLink? link;

  const EcommerceBanner({
    required this.id,
    required this.ecommerceId,
    required this.type,
    required this.dispositivo,
    required this.url,
    required this.ordem,
    required this.ativo,
    this.link,
  });

  /// `limparLink: true` remove o destino (senão `link: null` seria "não mexe").
  EcommerceBanner copyWith({
    int? ordem,
    bool? ativo,
    EcommerceBannerLink? link,
    bool limparLink = false,
  }) =>
      EcommerceBanner(
        id: id,
        ecommerceId: ecommerceId,
        type: type,
        dispositivo: dispositivo,
        url: url,
        ordem: ordem ?? this.ordem,
        ativo: ativo ?? this.ativo,
        link: limparLink ? null : (link ?? this.link),
      );
}
