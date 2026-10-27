abstract class ReferenciaMidia {
  int get id;
  String get url;
  int get referenciaId;
  bool get ePrincipal;
  bool get ePublica;
  String? get descricao;
  String? get tamanho;
  String? get cor;

  /// 'site' (vitrine/e-commerce) ou 'fornecedor' (uso interno: nunca pública nem capa).
  String get origem;

  factory ReferenciaMidia.create({
    required int id,
    required String url,
    required int referenciaId,
    required bool ePrincipal,
    required bool ePublica,
    String? descricao,
    String? tamanho,
    String? cor,
    String origem,
  }) = _ReferenciaMidiaImpl;
}

class _ReferenciaMidiaImpl implements ReferenciaMidia {
  @override
  final int id;
  @override
  final String url;
  @override
  final int referenciaId;
  @override
  final bool ePrincipal;
  @override
  final bool ePublica;

  @override
  final String? descricao;
  @override
  final String? tamanho;
  @override
  final String? cor;
  @override
  final String origem;

  _ReferenciaMidiaImpl({
    required this.id,
    required this.url,
    required this.referenciaId,
    required this.ePrincipal,
    required this.ePublica,
    this.descricao,
    this.tamanho,
    this.cor,
    this.origem = 'site',
  });
}

enum TipoReferenciaMidia { imagem, video, documento }

extension ReferenciaMidiaOrigem on ReferenciaMidia {
  bool get doFornecedor => origem == 'fornecedor';
}
