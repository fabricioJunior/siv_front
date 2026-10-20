import 'package:comercial/data/remote/dtos/relatorio_movimentacoes_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parse movimentações', () {
    final r = movimentacoesFromJson({
      'items': [
        {
          'id': 'romaneio:99:1',
          'dataHora': '2026-10-01T18:30:12-03:00',
          'tipo': 'venda',
          'produtoId': 5,
          'produtoNome': 'X',
          'referenciaIdExterno': 'R1',
          'descricao': null,
          'quantidade': 1,
          'responsavelId': 1,
          'responsavelNome': 'Ana',
          'documentoTipo': 'romaneio',
          'documentoId': 99,
        },
        {'id': 'x', 'dataHora': '2026-10-02T10:00:00-03:00', 'tipo': 'novo', 'produtoId': null, 'produtoNome': null, 'quantidade': 2},
      ],
      'meta': {'totalItems': 2, 'itemCount': 2, 'itemsPerPage': 50, 'totalPages': 1, 'currentPage': 1},
      'contagemPorTipo': {'venda': 1, 'compra': 1},
    });
    expect(r.items.first.documentoId, 99);
    expect(r.items.last.tipo, 'novo');
    expect(r.items.last.produtoId, isNull);
    expect(r.meta.totalItems, 2);
    expect(r.contagemPorTipo['venda'], 1);
  });
}
