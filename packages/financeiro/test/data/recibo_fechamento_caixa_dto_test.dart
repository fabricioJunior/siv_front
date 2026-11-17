import 'package:financeiro/data/remote/dtos/recibo_fechamento_caixa_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('despesas ausentes viram lista vazia', () {
    expect(ReciboFechamentoCaixaDto.fromJson({}).despesas, isEmpty);
  });

  test('despesas usam categoriaNome como origem', () {
    final recibo = ReciboFechamentoCaixaDto.fromJson({
      'despesas': [
        {
          'id': 1,
          'valor': 12.5,
          'descricao': 'Lanche',
          'categoriaNome': 'Alimentação',
          'dataHora': '2026-10-24T10:00:00Z',
          'operadorId': 3,
          'cancelado': true,
          'motivoCancelamento': 'erro',
        },
      ],
    });

    final d = recibo.despesas.single;
    expect(d.origem, 'Alimentação');
    expect(d.valor, 12.5);
    expect(d.cancelado, true);
    expect(d.motivoCancelamento, 'erro');
  });
}
