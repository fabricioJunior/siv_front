abstract class ReferenciaMidia {
  int get id;
  String get url;
  int get referenciaId;
  bool get ePrincipal;
  bool get ePublica;

  factory ReferenciaMidia.create({
    required int id,
    required String url,
    required int referenciaId,
    required bool ePrincipal,
    required bool ePublica,
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

  _ReferenciaMidiaImpl({
    required this.id,
    required this.url,
    required this.referenciaId,
    required this.ePrincipal,
    required this.ePublica,
  });
}

enum TipoReferenciaMidia { imagem, video, documento }
