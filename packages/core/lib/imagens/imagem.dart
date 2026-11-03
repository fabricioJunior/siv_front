import 'dart:typed_data';

class Imagem {
  final String? path;
  final String? url;
  final String? field;
  final String? descricao;
  final String? cor;
  final String? tamanho;
  final String? estampa;
  final Uint8List? bytes;

  Imagem({
    this.path,
    this.url,
    this.field,
    this.descricao,
    this.cor,
    this.tamanho,
    this.estampa,
    this.bytes,
  });

  Imagem copyWith({
    String? path,
    String? url,
    String? field,
    String? descricao,
    String? cor,
    String? tamanho,
    String? estampa,
    Uint8List? bytes,
  }) {
    return Imagem(
      path: path ?? this.path,
      url: url ?? this.url,
      field: field ?? this.field,
      descricao: descricao ?? this.descricao,
      cor: cor ?? this.cor,
      tamanho: tamanho ?? this.tamanho,
      estampa: estampa ?? this.estampa,
      bytes: bytes ?? this.bytes,
    );
  }
}
