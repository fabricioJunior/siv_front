import 'package:flutter_test/flutter_test.dart';
import 'package:promocoes/domain/models/elegibilidade.dart';

void main() {
  test('parse de varios cupons: codigo, descontoCuponsSomado e cupons aceitos', () {
    final r = ResultadoElegibilidade.fromJson({
      'cupomInvalido': null,
      'cupons': [
        {'codigo': 'CUP5', 'cupomId': 1},
        {'codigo': 'CUP8', 'cupomId': 2},
      ],
      'itens': [
        {
          'referenciaId': 10,
          'descontoCuponsSomado': 13,
          'opcoesElegiveis': [
            {
              'tipo': 'cupom',
              'id': 1,
              'nome': 'Cupom CUP5',
              'codigo': 'CUP5',
              'valorDesconto': 5,
              'valorFinalUnitario': 194,
            },
          ],
        },
      ],
    });

    expect(r.cuponsAceitos, ['CUP5', 'CUP8']);
    expect(r.itens.single.descontoCuponsSomado, 13);
    expect(r.itens.single.opcoesElegiveis.single.codigo, 'CUP5');
  });

  test('backend antigo (sem codigo/cupons/descontoCuponsSomado) continua parseando', () {
    final r = ResultadoElegibilidade.fromJson({
      'itens': [
        {
          'referenciaId': 10,
          'opcoesElegiveis': [
            {
              'tipo': 'cupom',
              'id': 1,
              'nome': 'Cupom X',
              'valorDesconto': 5,
              'valorFinalUnitario': 194,
            },
          ],
        },
      ],
    });

    expect(r.cuponsAceitos, isNull);
    expect(r.itens.single.descontoCuponsSomado, isNull);
    expect(r.itens.single.opcoesElegiveis.single.codigo, isNull);
  });
}
