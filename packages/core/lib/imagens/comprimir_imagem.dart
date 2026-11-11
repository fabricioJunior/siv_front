import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

const limiteBytesImagem = 1024 * 1024;

/// Reduz [bytes] para no máximo [maxBytes] (JPEG). Devolve o original se já couber
/// ou se não for decodificável.
Future<Uint8List> comprimirImagem(
  Uint8List bytes, {
  int maxBytes = limiteBytesImagem,
}) async {
  if (bytes.length <= maxBytes) return bytes;
  return compute(_comprimir, (bytes, maxBytes));
}

Uint8List _comprimir((Uint8List, int) args) {
  final (bytes, maxBytes) = args;
  final decodificada = img.decodeImage(bytes);
  if (decodificada == null) return bytes;
  var imagem = img.bakeOrientation(decodificada);
  if (max(imagem.width, imagem.height) > 2000) {
    imagem = imagem.width >= imagem.height
        ? img.copyResize(imagem, width: 2000)
        : img.copyResize(imagem, height: 2000);
  }
  var saida = Uint8List.fromList(img.encodeJpg(imagem, quality: 85));
  for (final q in [70, 55, 40]) {
    if (saida.length <= maxBytes) return saida;
    saida = Uint8List.fromList(img.encodeJpg(imagem, quality: q));
  }
  for (var i = 0; i < 6 && saida.length > maxBytes; i++) {
    imagem = img.copyResize(imagem, width: (imagem.width * 0.75).round());
    saida = Uint8List.fromList(img.encodeJpg(imagem, quality: 60));
  }
  return saida;
}
