import 'dart:typed_data';

/// Fora da web não há compressão nativa: quem chama usa o fallback em Dart.
Future<Uint8List?> comprimirImagemNativa(
  Uint8List bytes, {
  required int maxBytes,
  int ladoMaximo = 2000,
}) async => null;
