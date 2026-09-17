import 'package:core/data_sourcers.dart';
import 'package:core/isar_anotacoes.dart';
import 'package:estoque/data/local/dtos/produto_estoque_dto.dart';
import 'package:estoque/data/local/produto_estoque_query_mixin.dart';
import 'package:estoque/domain/data/datasourcers/i_produtos_estoque_local_datasource.dart';
import 'package:estoque/estoque.dart';

class ProdutosEstoqueLocalDatasource
    extends IsarLocalDataSourceBase<ProdutoEstoqueDto, ProdutoDoEstoque>
    with ProdutoEstoqueQueryMixin<ProdutoEstoqueDto>
    implements IProdutoEstoqueLocalDataSource {
  ProdutosEstoqueLocalDatasource({required super.getIsar});

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
  ProdutoEstoqueDto toDto(ProdutoDoEstoque entity) {
    return ProdutoEstoqueDto(
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

    // Restringe pelo índice de palavras (`nomePalavras`, `IndexType.value`
    // multiEntry) usando a 1ª palavra via `where()` (índice B-tree de
    // verdade, evita o full-scan) -- resto do texto (demais palavras +
    // tamanho/cor + substring exata) filtra em Dart sobre esse conjunto já
    // restrito, sem precisar de mais idas ao banco.
    final isarInstance = await getIsar();
    final candidatosDaPrimeiraPalavra = await isarInstance.txn(() {
      return isarInstance
          .collection<ProdutoEstoqueDto>()
          .where()
          .nomePalavrasElementStartsWith(termos.first)
          .findAll();
    });

    final demaisTermos = termos.skip(1);
    final candidatos = demaisTermos.isEmpty
        ? candidatosDaPrimeiraPalavra
        : candidatosDaPrimeiraPalavra.where(
            (dto) => demaisTermos.every(
              (termo) => dto.nomePalavras.any((p) => p.startsWith(termo)),
            ),
          );

    return buscarProdutosPorTextoDe(
      candidatos,
      texto,
      tamanho: tamanho,
      cor: cor,
    );
  }
}
