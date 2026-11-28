abstract class ReferenciaMidia {
  int get id;
  String get url;
  String? get urlMiniatura;
  int get referenciaId;
  bool get ePrincipal;
  bool get ePublica;
  String? get descricao;
  String? get tamanho;
  String? get cor;
  String? get estampa;

  /// 'site' | 'fornecedor' | 'chegada'
  String get origem;

  factory ReferenciaMidia.create({
    required int id,
    required String url,
    String? urlMiniatura,
    required int referenciaId,
    required bool ePrincipal,
    required bool ePublica,
    String? descricao,
    String? tamanho,
    String? cor,
    String? estampa,
    String origem,
  }) = _ReferenciaMidiaImpl;
}

class _ReferenciaMidiaImpl implements ReferenciaMidia {
  @override
  final int id;
  @override
  final String url;
  @override
  final String? urlMiniatura;
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
  final String? estampa;
  @override
  final String origem;

  _ReferenciaMidiaImpl({
    required this.id,
    required this.url,
    this.urlMiniatura,
    required this.referenciaId,
    required this.ePrincipal,
    required this.ePublica,
    this.descricao,
    this.tamanho,
    this.cor,
    this.estampa,
    this.origem = 'site',
  });
}

enum TipoReferenciaMidia { imagem, video, documento }

extension ReferenciaMidiaOrigem on ReferenciaMidia {
  bool get doFornecedor => origem == 'fornecedor';
  bool get daCHegada => origem == 'chegada';
  bool get doSite => origem == 'site';

  /// URL preferencial para miniatura: urlMiniatura se disponível, senão url.
  String get urlParaMiniatura => urlMiniatura ?? url;
}
