import 'package:comercial/data/remote/ecommerce_vitrine_remote_data_source.dart';
import 'package:comercial/domain/models/ecommerce_vitrine.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/http_fake.dart';

void main() {
  late HttpFake http;
  late EcommerceVitrineRemoteDataSource ds;

  setUp(() {
    http = HttpFake();
    ds = EcommerceVitrineRemoteDataSource(informacoesParaRequest: InfoFake(http));
  });

  test('GET devolve menu/home ordenados por ordem', () async {
    http.resposta = {
      'menu': [
        {'tipo': 'grupo', 'itemId': 2, 'ordem': 1, 'nome': 'G'},
        {'tipo': 'lista', 'itemId': 1, 'ordem': 0, 'nome': 'L', 'situacao': 'ativa'},
      ],
      'home': [],
    };
    final v = await ds.recuperar(9);

    expect(http.chamadas, ['GET /v1/e-commerce/9/vitrine']);
    expect(v.menu.map((i) => i.nome), ['L', 'G']);
    expect(v.menu.last.tipo, VitrineItemTipo.grupo);
  });

  test('salvar faz PUT /vitrine/:local com tipo, itemId e ordem', () async {
    await ds.salvar(9, VitrineLocal.home, [
      const EcommerceVitrineItem(tipo: VitrineItemTipo.lista, itemId: 5, ordem: 0, nome: 'L'),
    ]);

    expect(http.chamadas, ['PUT /v1/e-commerce/9/vitrine/home']);
    expect(http.bodies.single, {
      'itens': [
        {'tipo': 'lista', 'itemId': 5, 'ordem': 0},
      ],
    });
  });
}
