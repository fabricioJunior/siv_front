import 'package:financeiro/data/remote/dtos/contagem_do_caixa_item_dto.dart';
import 'package:financeiro/domain/models/contagem_do_caixa_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('"Cartão de débito" do backend vira cartaoDeDebito (não dinheiro)', () {
    final item = ContagemDoCaixaItemDto.fromJson({'valor': 179.1, 'tipoDocumento': 'Cartão de débito'});
    expect(item.tipoDocumento, TipoContagemDoCaixaItem.cartaoDeDebito);
  });

  test('"Cartão" continua cartao', () {
    final item = ContagemDoCaixaItemDto.fromJson({'valor': 1, 'tipoDocumento': 'Cartão'});
    expect(item.tipoDocumento, TipoContagemDoCaixaItem.cartao);
  });

  test('tipo desconhecido falha em vez de virar dinheiro', () {
    expect(
      () => ContagemDoCaixaItemDto.fromJson({'valor': 1, 'tipoDocumento': 'Criptomoeda'}),
      throwsFormatException,
    );
  });

  test('valorApi manda o rótulo que o backend aceita', () {
    expect(TipoContagemDoCaixaItem.cartaoDeDebito.valorApi, 'Cartão de débito');
    expect(TipoContagemDoCaixaItem.cartao.valorApi, 'cartao');
    expect(TipoContagemDoCaixaItem.pix.valorApi, 'pix');
  });
}
