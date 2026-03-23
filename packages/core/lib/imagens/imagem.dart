import 'dart:typed_data';

class Imagem {
  final String? path;
  final String? url;
  final String? field;
  final String? descricao;
  final Uint8List? bytes;

  Imagem({
    this.path,
    this.url,
    this.field,
    this.descricao,
    this.bytes,
  });

  Imagem copyWith({
    String? path,
    String? url,
    String? field,
    String? descricao,
  }) {
    return Imagem(
      path: path ?? this.path,
      url: url ?? this.url,
      field: field ?? this.field,
      descricao: descricao ?? this.descricao,
    );
  }
}
