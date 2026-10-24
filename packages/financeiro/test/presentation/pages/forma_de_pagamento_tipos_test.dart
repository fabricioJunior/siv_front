import 'package:financeiro/domain/models/forma_de_pagamento.dart';
import 'package:financeiro/presentation/pages/forma_de_pagamento_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('crédito mantém valor salvo "Cartão" e muda só o rótulo', () {
    expect(TiposFormaPagamento.cartaoCredito, 'Cartão');
    expect(TiposFormaPagamento.rotulo('Cartão'), 'Cartão de crédito');
    expect(TiposFormaPagamento.rotulo('Pix'), 'Pix');
  });

  test('tipos escolhíveis têm débito e não têm Troco', () {
    expect(FormaDePagamentoPage.tipos, contains('Cartão de débito'));
    expect(FormaDePagamentoPage.tipos, isNot(contains('Troco')));
  });
}
