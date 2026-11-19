import 'dart:async';
import 'dart:js_interop';
import 'dart:math';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Reduz [bytes] para JPEG de até [maxBytes] usando o decodificador/encoder do navegador
/// (assíncrono e bem mais rápido que o `package:image` em Dart compilado pra JS, que travava
/// a UI). Respeita a orientação EXIF. Devolve null se o navegador não conseguir (quem chama
/// cai no fallback).
Future<Uint8List?> comprimirImagemNativa(
  Uint8List bytes, {
  required int maxBytes,
  int ladoMaximo = 2000,
}) async {
  web.ImageBitmap? bitmap;
  try {
    bitmap = await web.window
        .createImageBitmap(web.Blob([bytes.toJS].toJS))
        .toDart;
    var escala = min(1.0, ladoMaximo / max(bitmap.width, bitmap.height));
    Uint8List? saida;
    // Qualidades decrescentes; se ainda grande, reduz as dimensões.
    for (var rodada = 0; rodada < 6; rodada++) {
      final largura = max(1, (bitmap.width * escala).round());
      final altura = max(1, (bitmap.height * escala).round());
      final canvas = web.HTMLCanvasElement()
        ..width = largura
        ..height = altura;
      final ctx = canvas.getContext('2d') as web.CanvasRenderingContext2D;
      ctx.fillStyle = '#fff'.toJS; // JPEG não tem transparência
      ctx.fillRect(0, 0, largura, altura);
      ctx.drawImage(bitmap, 0, 0, largura, altura);
      for (final qualidade in const [0.85, 0.7, 0.55, 0.4]) {
        saida = await _toJpeg(canvas, qualidade);
        if (saida == null) return null;
        if (saida.length <= maxBytes) return saida;
      }
      escala *= 0.75;
    }
    return saida;
  } catch (_) {
    return null;
  } finally {
    bitmap?.close();
  }
}

Future<Uint8List?> _toJpeg(web.HTMLCanvasElement canvas, double qualidade) async {
  final c = Completer<web.Blob?>();
  canvas.toBlob(((web.Blob? blob) => c.complete(blob)).toJS, 'image/jpeg', qualidade.toJS);
  final blob = await c.future;
  if (blob == null) return null;
  final buffer = await blob.arrayBuffer().toDart;
  return buffer.toDart.asUint8List();
}
