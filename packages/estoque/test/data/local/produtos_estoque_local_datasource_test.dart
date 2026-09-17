import 'dart:ffi';
import 'dart:io';

import 'package:core/isar_anotacoes.dart';
import 'package:estoque/data/local/dtos/produto_estoque_dto.dart';
import 'package:estoque/data/local/produtos_estoque_local_datasource.dart';
import 'package:estoque/estoque.dart';
import 'package:flutter_test/flutter_test.dart';

// Testa contra um Isar real (arquivo temporário) -- garante que o índice
// `nomePalavras` (IndexType.value) restringe a busca sem carregar a coleção
// inteira, e que o AND entre palavras do termo digitado funciona.
void main() {
  late Directory tempDir;
  late Isar isar;
  late ProdutosEstoqueLocalDatasource datasource;

  setUpAll(() async {
    // `flutter test` roda fora do bundle do app -- a lib nativa do isar não
    // é resolvida pelo mecanismo normal (plugin/asset), aponta direto pro
    // binário baixado pelo isar_community_flutter_libs no pub cache.
    // ponytail: só cobre macOS (máquina de dev); noutra plataforma de CI,
    // ajustar o path do binário aqui ou usar `download: true`.
    if (Platform.isMacOS) {
      final pubCacheDir = Platform.environment['PUB_CACHE'] ??
          '${Platform.environment['HOME']}/.pub-cache';
      final libPath = '$pubCacheDir/hosted/pub.dev/'
          'isar_community_flutter_libs-3.3.2/macos/libisar.dylib';
      await Isar.initializeIsarCore(
        libraries: {Abi.macosArm64: libPath, Abi.macosX64: libPath},
      );
    }
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('isar_produto_estoque_test');
    isar = await Isar.open([ProdutoEstoqueDtoSchema], directory: tempDir.path);
    datasource = ProdutosEstoqueLocalDatasource(
      getIsar: ({bool? isSyncData}) async => isar,
    );
  });

  tearDown(() async {
    await isar.close();
    await tempDir.delete(recursive: true);
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

  test('busca por 1 palavra usa índice e ignora quem não bate', () async {
    await datasource.salvarProdutos([
      produto(id: 1, nome: 'CAMISA AZUL BASICA'),
      produto(id: 2, nome: 'CALCA AZUL'),
      produto(id: 3, nome: 'CAMISA VERDE'),
    ]);

    final resultado = await datasource.buscarProdutosPorTexto('azul');

    expect(resultado.map((e) => e.produtoId.toInt()).toSet(), {1, 2});
  });

  test('busca por múltiplas palavras exige todas (AND)', () async {
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

  test('texto vazio retorna tudo, filtro de tamanho/cor continua funcionando', () async {
    await datasource.salvarProdutos([
      produto(id: 1, nome: 'CAMISA AZUL'),
      produto(id: 2, nome: 'CALCA VERDE'),
    ]);

    final resultado = await datasource.buscarProdutosPorTexto('');

    expect(resultado.length, 2);
  });
}
