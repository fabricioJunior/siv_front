/// Foto leve usada em contextos onde não temos o id completo da mídia
/// (ex: lista de esperadas retornada pelo endpoint de pedido de entrada).
class ReferenciaMidiaSimples {
  final String url;
  final String? urlMiniatura;

  /// 'site' | 'fornecedor' | 'chegada'
  final String origem;

  const ReferenciaMidiaSimples({
    required this.url,
    this.urlMiniatura,
    this.origem = 'site',
  });

  factory ReferenciaMidiaSimples.fromJson(Map<String, dynamic> j) =>
      ReferenciaMidiaSimples(
        url: j['url'] as String,
        urlMiniatura: j['urlMiniatura'] as String?,
        origem: j['origem'] as String? ?? 'site',
      );

  /// URL preferencial para miniatura.
  String get urlParaMiniatura => urlMiniatura ?? url;

  bool get doFornecedor => origem == 'fornecedor';
  bool get daChegada => origem == 'chegada';
  bool get doSite => origem == 'site';
}
