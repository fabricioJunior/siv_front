import 'package:comercial/domain/models/pedido_entrada.dart';
import 'package:comercial/domain/models/referencia_esperada.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('conferência: item lê estampaNome; liso e estampado são produtos distintos', () {
    final c = EntradaConferencia.fromJson({
      'itens': [
        {'produtoId': 1, 'idReferencia': 9, 'cor': 'Azul', 'tamanho': 'M', 'contado': 2, 'lido': 0},
        {
          'produtoId': 2,
          'idReferencia': 9,
          'cor': 'Azul',
          'tamanho': 'M',
          'estampaId': 4,
          'estampaNome': 'Floral',
          'contado': 3,
          'lido': 1,
        },
      ],
    });
    expect(c.itens[0].estampa, '');
    expect(c.itens[0].grade, 'Azul · M');
    expect(c.itens[1].estampa, 'Floral');
    expect(c.itens[1].estampaId, 4);
    expect(c.itens[1].grade, 'Azul · Floral · M');
    expect(c.itens.map((i) => i.produtoId).toSet().length, 2);
  });

  test('linha e divergência leem estampa; ausente = null', () {
    final l = EntradaLinha.fromJson({'id': 1, 'estampaId': 4, 'estampaNome': 'Floral'});
    expect(l.estampaNome, 'Floral');
    expect(EntradaLinha.fromJson({'id': 1}).estampaNome, isNull);
    final d = EntradaDivergencia.fromJson({
      'produtoId': 2,
      'grade': 'Azul · M · Floral',
      'estampaNome': 'Floral',
    });
    expect(d.estampaNome, 'Floral');
    expect(EntradaDivergencia.fromJson({'produtoId': 2}).estampaNome, isNull);
  });

  test('esperada: estampas e variações separam liso de estampado', () {
    final e = ReferenciaEsperada.fromJson({
      'id': 5,
      'nome': 'Aurora',
      'estampas': ['Floral'],
      'variacoes': [
        {'produtoId': 1, 'cor': 'Azul', 'tamanho': 'M', 'estampa': null, 'contado': 2},
        {'produtoId': 2, 'cor': 'Azul', 'tamanho': 'M', 'estampa': 'Floral'},
      ],
    });
    expect(e.estampas, ['Floral']);
    expect(e.variacoes.map((v) => v.grade), ['Azul · M', 'Azul · Floral · M']);
    expect(e.variacoes[0].contado, 2);
    expect(e.variacoes[1].contado, isNull);
    expect(ReferenciaEsperada.fromJson({'id': 1}).variacoes, isEmpty);
  });
}
