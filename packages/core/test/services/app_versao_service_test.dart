import 'package:core/versao.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sem release (build local) mostra só a versão', () {
    expect(AppVersaoService.rotuloDe('1.0.0+1', ''), 'v1.0.0+1');
    expect(AppVersaoService.rotuloDe('1.0.0+1', 'local'), 'v1.0.0+1');
    expect(AppVersaoService.rotuloDe('1.0.0+1', 'teste'), 'v1.0.0+1');
  });

  test('com release de deploy acrescenta os 7 primeiros caracteres do commit', () {
    expect(
      AppVersaoService.rotuloDe('1.0.0+1', '45eaa9b4c0ffee1234567890abcdef1234567890'),
      'v1.0.0+1 · 45eaa9b',
    );
  });

  test('release curto é mantido', () {
    expect(AppVersaoService.rotuloDe('2.1.0', 'abc12'), 'v2.1.0 · abc12');
  });
}
