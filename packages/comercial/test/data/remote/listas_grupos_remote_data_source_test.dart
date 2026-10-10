import 'package:comercial/data/remote/listas_grupos_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/http_fake.dart';

void main() {
  late HttpFake http;
  late ListasGruposRemoteDataSource ds;

  setUp(() {
    http = HttpFake({'id': 4, 'nome': 'Verão', 'ativo': true});
    ds = ListasGruposRemoteDataSource(informacoesParaRequest: InfoFake(http));
  });

  test('CRUD usa /v1/listas-personalizadas-grupos', () async {
    await ds.criar(nome: ' Verão ', descricao: '');
    await ds.atualizar(4, nome: 'Verão', descricao: 'Peças leves', ativo: false);
    await ds.excluir(4);

    expect(http.chamadas, [
      'POST /v1/listas-personalizadas-grupos',
      'PATCH /v1/listas-personalizadas-grupos/4',
      'DELETE /v1/listas-personalizadas-grupos/4',
    ]);
    expect(http.bodies[0], {'nome': 'Verão', 'descricao': null});
    expect(http.bodies[1], {'nome': 'Verão', 'descricao': 'Peças leves', 'ativo': false});
  });

  test('definirListas faz PUT com a posição como ordem', () async {
    await ds.definirListas(4, [30, 10, 20]);

    expect(http.chamadas, ['PUT /v1/listas-personalizadas-grupos/4/listas']);
    expect(http.bodies.single, {
      'itens': [
        {'listaId': 30, 'ordem': 0},
        {'listaId': 10, 'ordem': 1},
        {'listaId': 20, 'ordem': 2},
      ],
    });
  });

  test('detalhe traz as listas (aceita listaId ou id) e a página é paginada', () async {
    http.resposta = {
      'id': 4,
      'nome': 'Verão',
      'listas': [
        {'listaId': 10, 'nome': 'A', 'ordem': 1},
        {'id': 11, 'nome': 'B', 'ordem': 0},
      ],
    };
    final g = await ds.buscarPorId(4);
    http.resposta = {
      'items': [
        {'id': 4, 'nome': 'Verão'},
      ],
      'meta': {'totalPages': 3},
    };
    final p = await ds.listar(page: 2);

    expect(g.listas.map((l) => l.listaId), [10, 11]);
    expect(p.totalPages, 3);
    expect(http.chamadas.last, 'GET /v1/listas-personalizadas-grupos?page=2&limit=20');
  });
}
