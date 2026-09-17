import 'package:core/data_sourcers.dart';
import 'package:core/local_data_sourcers/database_configs/i_indexeddb_database_instance.dart';
import 'package:core/local_data_sourcers/database_configs/indexeddb_database_instance.dart';
import 'package:core/local_data_sourcers/indexeddb/indexeddb_schema.dart';
import 'package:estoque/data/local/produtos_estoque_indexeddb_datasource.dart';
import 'package:estoque/estoque.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idb_shim/idb_shim.dart';

// Mesma ideia do teste do Isar, mas contra um IndexedDB real em memória
// (idb_shim newIdbFactoryMemory) -- valida o índice multiEntry `nomePalavras`.
void main() {
  late IIndexedDbDatabaseInstance dbInstance;
  late ProdutosEstoqueIndexedDbDatasource datasource;

  setUp(() {
    dbInstance = IndexedDbDatabaseInstance(
      factory: newIdbFactoryMemory(),
      stores: const [
        IndexedDbStoreSpec(
          storeName: 'estoque_ProdutoEstoqueHiveDto',
          indexes: ['empresaId', 'referenciaId', 'idDoProduto'],
          multiEntryIndexes: ['nomePalavras'],
        ),
      ],
      version: 2,
    );
    datasource = ProdutosEstoqueIndexedDbDatasource(
      getDb: () => dbInstance.getDatabase(),
    );
  });

  tearDown(() async {
    await dbInstance.closeAllInstances();
  });

  ProdutoDoEstoque produto({required int id, required String nome}) {
    return ProdutoDoEstoque.create(
      empresaId: 1,
      referenciaId: id,
      referenciaIdExterno: 'ref-$id',
      produtoId: BigInt.from(id),
      produtoIdExterno: 'prod-$id',
      nome: nome,
      corId: 1,
      corNome: 'Azul',
      tamanhoId: 1,
      tamanhoNome: 'M',
      unidadeMedida: 'UN',
      saldo: 10,
    );
  }

  test('busca por 1 palavra usa índice multiEntry e ignora quem não bate', () async {
    await datasource.salvarProdutos([
      produto(id: 1, nome: 'CAMISA AZUL BASICA'),
      produto(id: 2, nome: 'CALCA AZUL'),
      produto(id: 3, nome: 'CAMISA VERDE'),
    ]);

    final resultado = await datasource.buscarProdutosPorTexto('azul');

    expect(resultado.map((e) => e.produtoId.toInt()).toSet(), {1, 2});
  });

  test('busca por múltiplas palavras exige todas (interseção)', () async {
    await datasource.salvarProdutos([
      produto(id: 1, nome: 'CAMISA AZUL BASICA'),
      produto(id: 2, nome: 'CALCA AZUL'),
      produto(id: 3, nome: 'CAMISA VERDE'),
    ]);

    final resultado = await datasource.buscarProdutosPorTexto('camisa azul');

    expect(resultado.map((e) => e.produtoId.toInt()).toSet(), {1});
  });

  test('busca ignora acento -- "calca" acha "CALÇA"', () async {
    await datasource.salvarProdutos([
      produto(id: 1, nome: 'CALÇA JEANS'),
      produto(id: 2, nome: 'CAMISA AZUL'),
    ]);

    final resultado = await datasource.buscarProdutosPorTexto('calca');

    expect(resultado.map((e) => e.produtoId.toInt()).toSet(), {1});
  });

  test('texto vazio retorna tudo', () async {
    await datasource.salvarProdutos([
      produto(id: 1, nome: 'CAMISA AZUL'),
      produto(id: 2, nome: 'CALCA VERDE'),
    ]);

    final resultado = await datasource.buscarProdutosPorTexto('');

    expect(resultado.length, 2);
  });
}
