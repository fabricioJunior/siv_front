import 'dart:io';

import 'package:core/imagens.dart';
import 'package:core/imagens/cache_imagem_service.dart';
import 'package:core/injecoes/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';

const _png1x1 = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, //
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0xF8, 0xFF, 0xFF, 0x3F,
  0x00, 0x05, 0xFE, 0x02, 0xFE, 0xA7, 0x35, 0x81, 0x84, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E,
  0x44, 0xAE, 0x42, 0x60, 0x82,
];

class _Cache implements ICacheImagemService {
  @override
  Future<void> deleteImagemComCacheKey(String cacheKey) async {}

  @override
  Future<File?> getImagemFileFromCache(String cacheKey) async =>
      File('${Directory.systemTemp.path}/imagem_view_teste.png').writeAsBytes(_png1x1);

  @override
  Future<void> updateImageInCache(String cacheKey, String url) async {}

  @override
  BaseCacheManager get cacheManager => throw UnimplementedError();
}

// Regressão: sem `fit` a foto grande aparecia no tamanho original, cortada (só o canto branco).
void main() {
  setUpAll(() {
    if (!sl.isRegistered<ICacheImagemService>()) sl.registerSingleton<ICacheImagemService>(_Cache());
  });

  testWidgets('ImagemViewWidget repassa o fit para a Image', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox(width: 160, height: 160, child: ImagemViewWidget(url: 'http://x/y.png', cacheKey: '1')),
      ),
    );
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pump();
    expect(tester.widget<Image>(find.byType(Image)).fit, BoxFit.cover);
  });
}
