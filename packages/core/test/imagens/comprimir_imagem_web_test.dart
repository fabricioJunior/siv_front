@TestOn('browser')
library;

import 'dart:math';
import 'dart:typed_data';

import 'package:core/imagens/comprimir_imagem.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('comprime foto grande no navegador para <= 1 MB e <= 2000 px', () async {
    final rnd = Random(1);
    final grande = img.Image(width: 3000, height: 2000);
    for (final p in grande) {
      p.setRgb(rnd.nextInt(256), rnd.nextInt(256), rnd.nextInt(256));
    }
    final original = Uint8List.fromList(img.encodePng(grande));
    expect(original.length, greaterThan(limiteBytesImagem));

    final saida = await comprimirImagem(original);

    expect(saida.length, lessThanOrEqualTo(limiteBytesImagem));
    final dec = img.decodeJpg(saida)!;
    expect(max(dec.width, dec.height), lessThanOrEqualTo(2000));
  });
}
