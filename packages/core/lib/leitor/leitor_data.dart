mixin LeitorData {
  String get codigoDeBarras;
  String get descricao;
  int get quantidade;
  int get idReferencia;
  String get tamanho;
  String get cor;
  double? get valor;
  int get id;

  Map<String, dynamic> get dados;
}
