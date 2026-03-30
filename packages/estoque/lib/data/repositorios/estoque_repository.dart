import 'package:core/paginacao.dart';
import 'package:core/paginacao/paginacao.dart';
import 'package:estoque/domain/data/datasourcers/i_produtos_estoque_local_datasource.dart';
import 'package:estoque/estoque.dart';

class EstoqueRepository implements IEstoqueRepository {
  final IEstoqueSaldoRemoteDataSource estoqueSaldoRemoteDataSource;
  final IProdutoEstoqueLocalDataSource produtosEstoqueLocalDataSource;
  final IPaginacaoDataSource paginacaoDataSource;

  EstoqueRepository({
    required this.estoqueSaldoRemoteDataSource,
    required this.produtosEstoqueLocalDataSource,
    required this.paginacaoDataSource,
  });

  @override
  Future<SaldoDoEstoque> obterSaldo({required FiltroProdutoDoEstoque filtro}) {
    return estoqueSaldoRemoteDataSource.obterSaldo(filtro: filtro);
  }

  @override
  Stream<Paginacao> syncEstoque() async* {
    var pagincao = await paginacaoDataSource.buscarPaginacao('estoque_sync');
    int page = pagincao?.ended == true ? 0 : (pagincao?.paginaAtual ?? 0);

    while (true) {
      var saldo = await estoqueSaldoRemoteDataSource.obterSaldo(
        filtro: FiltroProdutoDoEstoque(page: page, limit: 1000),
      );

      if (saldo.items.isEmpty) {
        var paginacao = Paginacao(
          key: 'estoque_sync',
          paginaAtual: page,
          totalPaginas: saldo.meta.totalPages,
          itensPorPagina: saldo.meta.itemsPerPage,
          totalItens: saldo.meta.totalItems,
          dataAtualizacao: DateTime.now(),
          ended: true,
        );
        await paginacaoDataSource.salvarPaginacao(paginacao);
        break;
      }

      await produtosEstoqueLocalDataSource.salvarProdutos(saldo.items);

      var pagicao = Paginacao(
        key: 'estoque_sync',
        paginaAtual: page,
        totalPaginas: saldo.meta.totalPages,
        itensPorPagina: saldo.meta.itemsPerPage,
        totalItens: saldo.meta.totalItems,
        dataAtualizacao: DateTime.now(),
      );
      await paginacaoDataSource.salvarPaginacao(pagicao);
      page++;
    }
  }
}
