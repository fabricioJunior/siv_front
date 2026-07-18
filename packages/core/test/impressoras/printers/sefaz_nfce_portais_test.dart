import 'package:core/impressoras/printers/sefaz_nfce_portais.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('sefazNfceUrl', () {
    test('monta URL a partir do cUF (2 primeiros digitos da chave)', () {
      const chave = '22260741108590000158650010000036961145483370';
      expect(
        sefazNfceUrl(chave),
        'https://webas.sefaz.pi.gov.br/nfce/22260741108590000158650010000036961145483370',
      );
    });

    test('aceita chave formatada com espacos/pontuacao', () {
      const chave = '3526 0112 3456 7800 0199 6500 1000 0012 3412 3456 7890';
      expect(
        sefazNfceUrl(chave),
        'https://www.nfce.fazenda.sp.gov.br/35260112345678000199650010000012341234567890',
      );
    });

    test('retorna null quando chave nao tem 44 digitos', () {
      expect(sefazNfceUrl('123'), isNull);
    });

    test('retorna null quando chave e nula', () {
      expect(sefazNfceUrl(null), isNull);
    });

    test('retorna null quando cUF nao esta mapeado', () {
      const chave = '99260741108590000158650010000036961145483370';
      expect(sefazNfceUrl(chave), isNull);
    });
  });
}
