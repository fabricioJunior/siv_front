import 'package:comercial/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lê resultado com contagem por venda e a lista de vendas rejeitadas', () {
    final importacao = ImportacaoVenda.fromJson({
      'id': 12,
      'situacao': 'concluida',
      'resultado': {
        'totalRecebidos': 3,
        'importados': 2,
        'itensImportados': 5,
        'romaneioIds': [901, 902],
        'rejeitados': [
          {'numeroVendaExterno': 9, 'motivo': 'Venda já importada (romaneio 7)'},
        ],
      },
    });

    expect(importacao.id, 12);
    expect(importacao.situacao, ImportacaoSituacao.concluida);
    expect(importacao.situacao.finalizada, isTrue);
    expect(importacao.resultado?.importados, 2);
    expect(importacao.resultado?.itensImportados, 5);
    expect(importacao.resultado?.rejeitados, [
      const ImportacaoVendaRejeitada(
        numeroVendaExterno: 9,
        motivo: 'Venda já importada (romaneio 7)',
      ),
    ]);
  });

  test('importação recém-criada (sem resultado) segue pendente e não finalizada', () {
    final importacao = ImportacaoVenda.fromJson({'id': 1, 'situacao': 'pendente'});

    expect(importacao.resultado, isNull);
    expect(importacao.situacao.finalizada, isFalse);
  });
}
