import 'package:core/data_sourcers.dart';
import 'package:estoque/data/local/dtos/produto_estoque_hive_dto.dart';
import 'package:estoque/data/local/produto_estoque_query_mixin.dart';
import 'package:estoque/domain/data/datasourcers/i_produtos_estoque_local_datasource.dart';
import 'package:estoque/estoque.dart';
import 'package:idb_shim/idb_shim.dart';

class ProdutosEstoqueIndexedDbDatasource
    extends IndexedDbLocalDataSourceBase<ProdutoEstoqueHiveDto, ProdutoDoEstoque>
    with ProdutoEstoqueQueryMixin<ProdutoEstoqueHiveDto>
    implements IProdutoEstoqueLocalDataSource {
  ProdutosEstoqueIndexedDbDatasource({required super.getDb})
      : super(
          storeName: 'estoque_ProdutoEstoqueHiveDto',
          fromStorage: ProdutoEstoqueHiveDto.fromStorage,
        );

  @override
  Future<void> excluirProduto(int idProduto) {
    return deleteById(idProduto);
  }

  @override
  Future<void> excluirProdutosWhere({DateTime? produtosAtualizadosAntesDe}) {
    // TODO: implement excluirProdutosWhere
    throw UnimplementedError();
  }

  @override
  Future<void> excluirTodosProdutos() {
    return deleteAll();
  }

  @override
  Future<List<ProdutoDoEstoque>> obterTodosProdutos() async {
    return (await fetchAll()).toList();
  }

  @override
  Future<void> salvarProduto(ProdutoDoEstoque produto) {
    return put(produto);
  }

  @override
  Future<void> salvarProdutos(List<ProdutoDoEstoque> produtos) {
    return putAll(produtos);
  }

  @override
  ProdutoEstoqueHiveDto toDto(ProdutoDoEstoque entity) {
    return ProdutoEstoqueHiveDto(
      idDoProduto: entity.produtoId.toInt(),
      produtoIdExterno: entity.produtoIdExterno,
      nome: entity.nome,
      nomePalavras: tokenizarNomeDoProduto(entity.nome),
      corId: entity.corId,
      corNome: entity.corNome,
      empresaId: entity.empresaId,
      referenciaId: entity.referenciaId,
      referenciaIdExterno: entity.referenciaIdExterno,
      saldo: entity.saldo,
      tamanhoId: entity.tamanhoId,
      tamanhoNome: entity.tamanhoNome,
      unidadeMedida: entity.unidadeMedida,
      atualizadoEm: entity.atualizadoEm,
    );
  }

  @override
  Future<ProdutoDoEstoque?> obterProduto(int id) {
    return fetchById(id);
  }

  @override
  Future<SaldoDoEstoque> obterSaldo({
    required FiltroProdutoDoEstoque filtro,
  }) async {
    // Pré-filtra pelos índices de igualdade disponíveis (interseção quando
    // mais de um filtro setado) antes de cair no filtro/sort/paginação em
    // memória do mixin -- evita carregar a store inteira quando dá pra
    // restringir por empresa/referência/produto primeiro.
    final candidatosPorIndice = <Set<int>>[];

    if (filtro.empresaIds.isNotEmpty) {
      candidatosPorIndice.add(
        await _idsPorIndice('empresaId', filtro.empresaIds),
      );
    }
    if (filtro.referenciaIds.isNotEmpty) {
      candidatosPorIndice.add(
        await _idsPorIndice('referenciaId', filtro.referenciaIds),
      );
    }
    if (filtro.produtoIds.isNotEmpty) {
      candidatosPorIndice.add(
        await _idsPorIndice('idDoProduto', filtro.produtoIds),
      );
    }

    if (candidatosPorIndice.isEmpty) {
      return obterSaldoDe(await fetchAll(), filtro);
    }

    final idsRestritos = candidatosPorIndice.reduce(
      (a, b) => a.intersection(b),
    );
    final candidatos = await fetchManyByIds(idsRestritos);

    return obterSaldoDe(candidatos, filtro);
  }

  Future<Set<int>> _idsPorIndice(String indexName, Iterable<int> valores) async {
    final ids = <int>{};
    for (final valor in valores) {
      final itens = await fetchByIndex(indexName, valor);
      ids.addAll(itens.map((e) => e.dataBaseId));
    }
    return ids;
  }

  @override
  Future<List<ProdutoDoEstoque>> buscarProdutosPorTexto(
    String texto, {
    String? tamanho,
    String? cor,
  }) async {
    final termos = tokenizarNomeDoProduto(texto);
    if (termos.isEmpty) {
      return buscarProdutosPorTextoDe(
        await fetchAll(),
        texto,
        tamanho: tamanho,
        cor: cor,
      );
    }

    // Restringe pelo índice multiEntry `nomePalavras` (prefixo por palavra)
    // antes de cair no filtro em memória -- interseção quando o termo
    // digitado tem mais de uma palavra.
    final idsPorTermo = await Future.wait(
      termos.map((termo) => _idsPorPrefixoDePalavra(termo)),
    );
    final idsRestritos = idsPorTermo.reduce((a, b) => a.intersection(b));
    final candidatos = await fetchManyByIds(idsRestritos);

    return buscarProdutosPorTextoDe(
      candidatos,
      texto,
      tamanho: tamanho,
      cor: cor,
    );
  }

  Future<Set<int>> _idsPorPrefixoDePalavra(String prefixo) async {
    final itens = await fetchByIndexRange(
      'nomePalavras',
      KeyRange.bound(prefixo, '$prefixo￿'),
    );
    return itens.map((e) => e.dataBaseId).toSet();
  }
}
