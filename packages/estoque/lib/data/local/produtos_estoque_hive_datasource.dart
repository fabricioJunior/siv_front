import 'package:core/data_sourcers.dart';
import 'package:estoque/data/local/dtos/produto_estoque_hive_dto.dart';
import 'package:estoque/data/local/produto_estoque_query_mixin.dart';
import 'package:estoque/domain/data/datasourcers/i_produtos_estoque_local_datasource.dart';
import 'package:estoque/estoque.dart';

class ProdutosEstoqueHiveDatasource
    extends HiveLocalDataSourceBase<ProdutoEstoqueHiveDto, ProdutoDoEstoque>
    with ProdutoEstoqueQueryMixin<ProdutoEstoqueHiveDto>
    implements IProdutoEstoqueLocalDataSource {
  ProdutosEstoqueHiveDatasource({required super.getBox});

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
}
