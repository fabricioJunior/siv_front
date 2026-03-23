abstract class ReferenciaMidia {
  int get id;
  String get url;
  int get referenciaId;
  bool get ePrincipal;
  bool get ePublica;
  String? get descricao;

  factory ReferenciaMidia.create({
    required int id,
    required String url,
    required int referenciaId,
    required bool ePrincipal,
    required bool ePublica,
    String? descricao,
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

  _ReferenciaMidiaImpl({
    required this.id,
    required this.url,
    required this.referenciaId,
    required this.ePrincipal,
    required this.ePublica,
    this.descricao,
  });
}

enum TipoReferenciaMidia { imagem, video, documento }
