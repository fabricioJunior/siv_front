import 'package:comercial/data/remote/dtos/pedido_item_dto.dart';
import 'package:comercial/data/remote/dtos/romaneio_item_devolvido_dto.dart';
import 'package:comercial/data/remote/dtos/romaneio_item_dto.dart';
import 'package:comercial/presentation/widgets/rotulo_variacao.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DTOs de item leem estampaNome, tolerando ausente/null', () {
    expect(PedidoItemDto.fromJson({'estampaNome': 'Floral'}).estampaNome, 'Floral');
    expect(PedidoItemDto.fromJson({'estampaNome': null}).estampaNome, isNull);
    expect(PedidoItemDto.fromJson({}).estampaNome, isNull);
    expect(RomaneioItemDto.fromJson({'estampaNome': 'Liso'}).estampaNome, 'Liso');
    expect(RomaneioItemDto.fromJson({}).estampaNome, isNull);
    expect(
      RomaneioItemDevolvidoDto.fromJson({'estampaNome': 'Liso'}).estampaNome,
      'Liso',
    );
    expect(RomaneioItemDevolvidoDto.fromJson({}).estampaNome, isNull);
  });

  test('rotuloVariacao mostra estampa só quando existe', () {
    expect(
      rotuloVariacao(cor: 'Bege', estampa: 'Floral', tamanho: 'M'),
      'Cor: Bege  •  Estampa: Floral  •  Tamanho: M',
    );
    expect(rotuloVariacao(cor: 'Bege', estampa: ' ', tamanho: 'M'),
        'Cor: Bege  •  Tamanho: M');
    expect(rotuloVariacao(cor: 'Bege', estampa: null, tamanho: 'M', tamanhoRotulo: 'Tam'),
        'Cor: Bege  •  Tam: M');
  });
}
