import 'package:estoque/data/local/dtos/produto_estoque_hive_dto.dart';
import 'package:estoque/data/remote/dtos/produto_do_estoque_dto.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _json({Object? estampa = 'Floral', bool inclui = true}) => {
      'empresaId': 1,
      'referenciaId': 2,
      'referenciaIdExterno': null,
      'produtoId': '3',
      'produtoIdExterno': null,
      'nome': 'Blusa',
      'corId': 1,
      'corNome': 'Azul',
      'tamanhoId': 1,
      'tamanhoNome': 'M',
      'unidadeMedida': null,
      'saldo': 1.0,
      if (inclui) 'estampaNome': estampa,
    };

void main() {
  test('remote DTO lê estampaNome, tolerando null e ausente', () {
    expect(ProdutoDoEstoqueDto.fromJson(_json()).estampaNome, 'Floral');
    expect(ProdutoDoEstoqueDto.fromJson(_json(estampa: null)).estampaNome, isNull);
    expect(ProdutoDoEstoqueDto.fromJson(_json(inclui: false)).estampaNome, isNull);
  });

  test('hive DTO grava/lê estampaNome e aceita registro antigo sem a chave', () {
    final dto = ProdutoEstoqueHiveDto.fromStorage({
      ...ProdutoEstoqueHiveDto(
        idDoProduto: 3,
        produtoIdExterno: null,
        nome: 'Blusa',
        nomePalavras: const ['blusa'],
        corId: 1,
        corNome: 'Azul',
        empresaId: 1,
        referenciaId: 2,
        referenciaIdExterno: null,
        saldo: 1,
        tamanhoId: 1,
        tamanhoNome: 'M',
        unidadeMedida: null,
        estampaNome: 'Floral',
      ).storageProperties,
    });
    expect(dto.estampaNome, 'Floral');
    final antigo = ProdutoEstoqueHiveDto.fromStorage(
      {...dto.storageProperties}..remove('estampaNome'),
    );
    expect(antigo.estampaNome, isNull);
  });
}
