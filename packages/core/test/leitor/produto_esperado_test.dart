import 'package:core/leitor/produto_esperado.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('temCodigo aceita qualquer código do produto', () {
    const p = ProdutoEsperado(
      id: 1,
      codigoDeBarras: 'A',
      codigosDeBarras: ['A', 'B'],
      descricao: 'x',
      esperado: 1,
    );
    expect(p.temCodigo('A'), isTrue);
    expect(p.temCodigo('B'), isTrue);
    expect(p.temCodigo('C'), isFalse);
    expect(p.temCodigo(null), isFalse);
  });
}
