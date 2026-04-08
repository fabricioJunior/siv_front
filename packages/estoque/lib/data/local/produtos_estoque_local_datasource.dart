import 'package:core/data_sourcers.dart';
import 'package:estoque/data/local/dtos/produto_estoque_dto.dart';
import 'package:estoque/domain/data/datasourcers/i_produtos_estoque_local_datasource.dart';
import 'package:estoque/domain/models/filtro_produto_do_estoque.dart';
import 'package:estoque/domain/models/paginacao_do_estoque.dart';
import 'package:estoque/domain/models/produto_do_estoque.dart';
import 'package:estoque/domain/models/saldo_do_estoque.dart';

class ProdutosEstoqueLocalDatasource
    extends IsarLocalDataSourceBase<ProdutoEstoqueDto, ProdutoDoEstoque>
    implements IProdutoEstoqueLocalDataSource {
  ProdutosEstoqueLocalDatasource({required super.getIsar});

  @override
  Future<SaldoDoEstoque> obterSaldo({
    required FiltroProdutoDoEstoque filtro,
  }) async {
    final produtos = await fetchAll();
    final termosBusca = <String>{
      ...filtro.produtoIdExternos,
      ...filtro.referenciaIdExternos,
    }.map(_normalizarTexto).where((termo) => termo.isNotEmpty).toSet();

    final filtrados = produtos.where((produto) {
      if (filtro.empresaIds.isNotEmpty &&
          !filtro.empresaIds.contains(produto.empresaId)) {
        return false;
      }
      if (filtro.referenciaIds.isNotEmpty &&
          !filtro.referenciaIds.contains(produto.referenciaId)) {
        return false;
      }
      if (filtro.produtoIds.isNotEmpty &&
          !filtro.produtoIds.contains(produto.produtoId.toInt())) {
        return false;
      }
      if (filtro.corIds.isNotEmpty && !filtro.corIds.contains(produto.corId)) {
        return false;
      }
      if (filtro.tamanhoIds.isNotEmpty &&
          !filtro.tamanhoIds.contains(produto.tamanhoId)) {
        return false;
      }
      if (termosBusca.isEmpty) {
        return true;
      }

      final nome = _normalizarTexto(produto.nome);
      final produtoIdExterno = _normalizarTexto(produto.produtoIdExterno ?? '');
      final referenciaIdExterno = _normalizarTexto(
        produto.referenciaIdExterno ?? '',
      );

      return termosBusca.any(
        (termo) =>
            nome.contains(termo) ||
            produtoIdExterno.contains(termo) ||
            referenciaIdExterno.contains(termo),
      );
    }).toList()..sort((a, b) => a.produtoId.compareTo(b.produtoId));

    final totalItems = filtrados.length;
    final totalPages = totalItems == 0
        ? 0
        : ((totalItems - 1) ~/ filtro.limit) + 1;
    final inicioCalculado = (filtro.page - 1) * filtro.limit;
    final inicio = inicioCalculado < 0
        ? 0
        : (inicioCalculado > totalItems ? totalItems : inicioCalculado);
    final fimCalculado = inicio + filtro.limit;
    final fim = fimCalculado > totalItems ? totalItems : fimCalculado;
    final itensPaginados = inicio < fim
        ? filtrados.sublist(inicio, fim)
        : const <ProdutoDoEstoque>[];

    return SaldoDoEstoque(
      meta: PaginacaoDoEstoque(
        totalItems: totalItems,
        itemCount: itensPaginados.length,
        itemsPerPage: filtro.limit,
        totalPages: totalPages,
        currentPage: filtro.page,
      ),
      items: itensPaginados,
    );
  }

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

String _normalizarTexto(String valor) {
  return valor.trim().toLowerCase();
}
