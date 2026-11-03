import 'package:empresas/domain/entities/integracao_infinity_pay.dart';
import 'package:flutter_test/flutter_test.dart';

import '../doubles/infinity_pay_fakes.dart';

IntegracaoInfinityPay _de(Map<String, String> over) =>
    IntegracaoInfinityPay.fromParametros(
      ServidorParametros({...parametrosBase(), ...over}).lista(),
    );

void main() {
  test('fromParametros lê S/N e textos', () {
    final c = _de({
      'INTEGRACAO_INFINITY_PAY_HABILITADA': 'S',
      'INTEGRACAO_INFINITY_PAY_API_HANDLE': 'vale',
      'INTEGRACAO_INFINITY_PAY_PIX_HABILITADO': 'N',
      'INTEGRACAO_INFINITY_PAY_PARCELAS_SEM_JUROS': '3',
    });
    expect(c.habilitada, isTrue);
    expect(c.handle, 'vale');
    expect(c.pixHabilitado, isFalse);
    expect(c.parcelasSemJuros, 3);
    expect(c.urlSiteEmpresa, 'https://loja.com.br');
    expect(c.mercadoPagoHabilitado, isTrue);
    expect(c.openPixHabilitado, isFalse);
  });

  test('valor ausente: Pix padrão S, resto vazio', () {
    final c = IntegracaoInfinityPay.fromParametros(const []);
    expect(c.habilitada, isFalse);
    expect(c.pixHabilitado, isTrue);
    expect(c.handle, '');
    expect(c.parcelasSemJuros, isNull);
  });

  test('toParametros é o inverso de fromParametros', () {
    final base = parametrosBase();
    final c = IntegracaoInfinityPay.fromParametros(
      ServidorParametros(base).lista(),
    );
    final p = c.toParametros();
    for (final campo in CampoInfinityPay.values) {
      expect(p[campo.chave], base[campo.chave], reason: campo.chave);
    }
  });

  test('comValor normaliza handle', () {
    const c = IntegracaoInfinityPay();
    expect(
      c.comValor(CampoInfinityPay.handle, r'$valedoceara').handle,
      'valedoceara',
    );
    expect(
      c.comValor(CampoInfinityPay.handle, ' vale doceara ').handle,
      'valedoceara',
    );
  });
}
