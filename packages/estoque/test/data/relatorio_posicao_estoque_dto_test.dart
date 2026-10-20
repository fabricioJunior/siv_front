import 'package:estoque/data/remote/dtos/relatorio_posicao_estoque_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parse posição de estoque', () {
    final r = posicaoEstoqueFromJson({
      'dataReferencia': '2026-10-18',
      'baseValor': 'venda',
      'resumo': {'valorEstoque': 61537.9, 'pecas': 621, 'skusAtivos': 372, 'emRuptura': 3},
      'items': [
        {'categoriaId': 1, 'categoriaNome': 'CALÇA', 'pecas': 166, 'valor': 19733.9, 'percentual': 32.1, 'emRuptura': 1},
        {'categoriaId': null, 'categoriaNome': 'Sem categoria', 'pecas': 0, 'valor': 0, 'percentual': 0},
      ],
    });
    expect(r.baseValor, 'venda');
    expect(r.resumo.pecas, 621);
    expect(r.items.first.categoriaNome, 'CALÇA');
    expect(r.items.last.categoriaId, isNull);
    expect(r.items.last.emRuptura, 0);
  });
}
