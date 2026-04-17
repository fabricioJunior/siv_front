import 'dart:typed_data';

class Imagem {
  final String? path;
  final String? url;
  final String? field;
  final String? descricao;
  final String? cor;
  final String? tamanho;
  final Uint8List? bytes;

  Imagem({
    this.path,
    this.url,
    this.field,
    this.descricao,
    this.cor,
    this.tamanho,
    this.bytes,
  });

  Imagem copyWith({
    String? path,
    String? url,
    String? field,
    String? descricao,
    String? cor,
    String? tamanho,
    Uint8List? bytes,
  }) {
    return Imagem(
      path: path ?? this.path,
      url: url ?? this.url,
      field: field ?? this.field,
      descricao: descricao ?? this.descricao,
      cor: cor ?? this.cor,
      tamanho: tamanho ?? this.tamanho,
      bytes: bytes ?? this.bytes,
    );
  }
}
