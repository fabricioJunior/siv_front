import 'package:flutter_test/flutter_test.dart';
import 'package:produtos/data/remote/dtos/produto_dto.dart';

void main() {
  group('ProdutoDto.fromJson', () {
    test('deriva corId/tamanhoId/estampaId dos objetos aninhados (GET /produtos não serializa os ids)', () {
      final dto = ProdutoDto.fromJson({
        'id': 1,
        'idExterno': 'x',
        'cor': {'id': 9, 'nome': 'azul bebe', 'inativo': false},
        'tamanho': {'id': 14, 'nome': 'UN', 'inativo': false},
        'estampa': {'id': 3, 'nome': 'GROGU', 'inativo': false},
      });

      expect(dto.corId, 9);
      expect(dto.tamanhoId, 14);
      expect(dto.estampaId, 3);
    });

    test('sem estampa mantém estampaId nulo; ids simples têm prioridade', () {
      final dto = ProdutoDto.fromJson({
        'id': 1,
        'idExterno': 'x',
        'corId': 5,
        'cor': {'id': 9, 'nome': 'azul bebe', 'inativo': false},
        'tamanho': {'id': 14, 'nome': 'UN', 'inativo': false},
      });

      expect(dto.corId, 5);
      expect(dto.estampaId, isNull);
    });
  });
}
