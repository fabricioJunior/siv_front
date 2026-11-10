import 'package:core/leitor/produto_esperado.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('grade do esperado inclui a estampa só quando existe', () {
    const liso = ProdutoEsperado(
        id: 1, codigoDeBarras: '1', descricao: 'x', cor: 'Azul', tamanho: 'M', esperado: 1);
    const estampado = ProdutoEsperado(
        id: 2,
        codigoDeBarras: '2',
        descricao: 'x',
        cor: 'Azul',
        tamanho: 'M',
        estampa: 'Floral',
        esperado: 1);
    expect(liso.grade, 'Azul · M');
    expect(estampado.grade, 'Azul · Floral · M');
  });
}
