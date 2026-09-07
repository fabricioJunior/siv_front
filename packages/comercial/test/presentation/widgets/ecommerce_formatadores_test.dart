import 'package:comercial/presentation/widgets/ecommerce_formatadores.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatarMoedaEcommerce separa milhar e mantém duas casas', () {
    expect(formatarMoedaEcommerce(84210), 'R\$ 84.210,00');
    expect(formatarMoedaEcommerce(9.5), 'R\$ 9,50');
    expect(formatarMoedaEcommerce(-12.3), 'R\$ -12,30');
  });

  test('pluralizarEcommerce escreve as duas formas sem parênteses', () {
    expect(pluralizarEcommerce(1, 'referência', 'referências'), '1 referência');
    expect(pluralizarEcommerce(2, 'referência', 'referências'), '2 referências');
    expect(pluralizarEcommerce(0, 'referência', 'referências'), '0 referências');
  });
}
