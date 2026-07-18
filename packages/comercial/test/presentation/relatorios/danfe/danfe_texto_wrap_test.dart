import 'package:comercial/presentation/relatorios/danfe/danfe_texto_wrap.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('quebrarLinhaDanfe', () {
    test('nao quebra texto que cabe na largura', () {
      expect(quebrarLinhaDanfe('Produto curto', 32), ['Produto curto']);
    });

    test('quebra descricao longa sem cortar palavra no meio', () {
      final linhas = quebrarLinhaDanfe(
        'Produto com uma descricao bem longa que ultrapassa a largura',
        32,
      );

      for (final linha in linhas) {
        expect(linha.length, lessThanOrEqualTo(32));
      }
      // Nenhuma palavra original deve ter sido dividida entre linhas.
      expect(linhas.join(' ').replaceAll(RegExp(r'\s+'), ' '),
          'Produto com uma descricao bem longa que ultrapassa a largura');
    });

    test('forca quebra de palavra maior que a largura da coluna', () {
      final linhas = quebrarLinhaDanfe('X' * 50, 32);

      expect(linhas, hasLength(2));
      expect(linhas[0].length, 32);
      expect(linhas[1].length, 18);
    });
  });

  group('linhaComValorDireitaDanfe', () {
    test('junta esquerda e direita na mesma linha quando cabe', () {
      final linhas = linhaComValorDireitaDanfe('1 UN x R\$ 10,00', 'R\$ 10,00', 32);

      expect(linhas, hasLength(1));
      expect(linhas.single.length, 32);
      expect(linhas.single.endsWith('R\$ 10,00'), isTrue);
      expect(linhas.single.startsWith('1 UN x R\$ 10,00'), isTrue);
    });

    test('poe valor em linha propria alinhado a direita quando nao cabe', () {
      // Ultima linha da esquerda (28 chars) + espaco + direita (12 chars)
      // excede as 32 colunas -- o valor precisa ir pra linha propria.
      final linhas = linhaComValorDireitaDanfe(
        'X' * 28,
        'R\$ 1.234,56',
        32,
      );

      expect(linhas.last.length, 32);
      expect(linhas.last.trim(), 'R\$ 1.234,56');
    });
  });
}
