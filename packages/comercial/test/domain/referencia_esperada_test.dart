import 'package:comercial/domain/models/referencia_esperada.dart';
import 'package:flutter_test/flutter_test.dart';

ReferenciaEsperada _e(int id, String nome, {int? esperado, String? codigo}) =>
    ReferenciaEsperada(
      id: id,
      nome: nome,
      codigoNoFornecedor: codigo,
      quantidadeEsperada: esperado,
    );

void main() {
  test('lê a resposta da API: status, grade, foto e quantidade', () {
    final e = ReferenciaEsperada.fromJson({
      'id': 5,
      'nome': 'Aurora',
      'idExterno': 'DL-2231',
      'foto': 'https://r2/x.jpg',
      'status': ['nova', 'aguardandoPrimeiraEntrada'],
      'resumoGrade': 'Sem variações',
      'quantidadeEsperada': 24,
    });

    expect(e.nova, isTrue);
    expect(e.aguardandoPrimeiraEntrada, isTrue);
    expect(e.aguardandoReposicao, isFalse);
    expect(e.foto, 'https://r2/x.jpg');
    expect(e.codigoNoFornecedor, 'DL-2231');
    expect(e.quantidadeEsperada, 24);
  });

  group('situação do contado × esperado (só informa)', () {
    test('sem contagem', () {
      expect(_e(1, 'a', esperado: 10).situacao(0), SituacaoContagemEsperada.naoContada);
    });
    test('abaixo do esperado é parcial (âmbar)', () {
      expect(_e(1, 'a', esperado: 10).situacao(7), SituacaoContagemEsperada.parcial);
    });
    test('igual ou acima é completa (verde)', () {
      expect(_e(1, 'a', esperado: 10).situacao(10), SituacaoContagemEsperada.completa);
      expect(_e(1, 'a', esperado: 10).situacao(12), SituacaoContagemEsperada.completa);
    });
    test('sem quantidade esperada, só "contada"', () {
      expect(_e(1, 'a').situacao(3), SituacaoContagemEsperada.contada);
    });
  });

  test('ordem: não contadas primeiro, contadas por último; dentro, por nome', () {
    final lista = ordenarEsperadas(
      [_e(1, 'Bella'), _e(2, 'Aurora'), _e(3, 'Cecília'), _e(4, 'Dália')],
      {1: 5, 3: 2},
    );

    expect(lista.map((e) => e.id), [2, 4, 1, 3]);
  });

  test('busca ignora acento e caixa; acha por nome, código do fornecedor e REF', () {
    final e = _e(887004302, 'Áurora', codigo: 'DL-2231');

    expect(esperadaCorresponde(e, 'aurora'), isTrue);
    expect(esperadaCorresponde(e, 'ÁURORA'), isTrue);
    expect(esperadaCorresponde(e, 'dl-2231'), isTrue);
    expect(esperadaCorresponde(e, '2231'), isTrue);
    expect(esperadaCorresponde(e, '887004302'), isTrue);
    expect(esperadaCorresponde(e, 'bella'), isFalse);
    expect(esperadaCorresponde(e, '  '), isTrue);
  });
}
