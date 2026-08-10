import 'package:empresas/domain/coordenadas_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseCoordenadas', () {
    test('parseia DMS copiado do Google Maps', () {
      final resultado = parseCoordenadas('2°54\'49.7"S 41°45\'15.6"W');

      expect(resultado, isNotNull);
      expect(resultado!.$1, closeTo(-2.9138, 0.001));
      expect(resultado.$2, closeTo(-41.7543, 0.001));
    });

    test('parseia decimal separado por vírgula', () {
      final resultado = parseCoordenadas('-2.9138, -41.7543');

      expect(resultado, isNotNull);
      expect(resultado!.$1, -2.9138);
      expect(resultado.$2, -41.7543);
    });

    test('parseia decimal separado por espaço', () {
      final resultado = parseCoordenadas('-2.9138 -41.7543');

      expect(resultado, isNotNull);
      expect(resultado!.$1, -2.9138);
      expect(resultado.$2, -41.7543);
    });

    test('retorna null para texto inválido', () {
      expect(parseCoordenadas('texto qualquer'), isNull);
    });
  });
}
