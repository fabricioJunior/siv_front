import 'package:core/paginacao.dart';
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
  Future<SaldoDoEstoque> obterSaldo({
    required FiltroProdutoDoEstoque filtro,
  }) async {
    return produtosEstoqueLocalDataSource.obterSaldo(filtro: filtro);
  }

  @override
  Future<SaldoDoEstoque> sincronizarSaldo({
    required FiltroProdutoDoEstoque filtro,
  }) async {
    final saldo = await estoqueSaldoRemoteDataSource.obterSaldo(filtro: filtro);
    await produtosEstoqueLocalDataSource.salvarProdutos(saldo.items);
    return saldo;
  }

  @override
  Stream<Paginacao> syncEstoque() async* {
    var paginacaoAnterior = await paginacaoDataSource.buscarPaginacao('estoque_sync');

    final bool syncAnteriorConcluida = paginacaoAnterior?.ended == true;
    final int page = syncAnteriorConcluida ? 0 : (paginacaoAnterior?.paginaAtual ?? 0);

    // Só aplica filtro de data incremental quando a sync anterior completou.
    // Se estava incompleta, faz sync completa para garantir consistência.
    //
    // `atualizadoEm` no backend é gravado em UTC (UTC_TIMESTAMP() nos
    // triggers de estoque). DateTime.now() é hora LOCAL do device -- num
    // device em UTC-3 (Brasil), isso fazia o corte da janela de sync ficar
    // sistematicamente ~3h atrasado em relação ao instante real, excluindo
    // da sync qualquer mudança de estoque das últimas ~3h (ex: uma venda
    // que acabou de baixar o saldo). .toUtc() aqui e no fallback abaixo
    // alinha o cursor com o mesmo referencial de tempo do backend.
    final DateTime? ultimaAtualizacaoInicio = syncAnteriorConcluida
        ? paginacaoAnterior!.dataAtualizacao?.toUtc()
        : null;
    final DateTime? ultimaAtualizacaoFim =
        syncAnteriorConcluida ? DateTime.now().toUtc() : null;

    var paginaAtual = page;

    while (true) {
      var saldo = await estoqueSaldoRemoteDataSource.obterSaldo(
        filtro: FiltroProdutoDoEstoque(
          page: paginaAtual,
          limit: 1000,
          ultimaAtualizacaoInicio: ultimaAtualizacaoInicio,
          ultimaAtualizacaoFim: ultimaAtualizacaoFim,
        ),
      );

      if (saldo.items.isEmpty) {
        var paginacao = Paginacao(
          key: 'estoque_sync',
          paginaAtual: paginaAtual,
          totalPaginas: saldo.meta.totalPages,
          itensPorPagina: saldo.meta.itemsPerPage,
          itensProcessadosNaPagina: 0,
          totalItens: saldo.meta.totalItems,
          dataAtualizacao: ultimaAtualizacaoFim ?? DateTime.now().toUtc(),
          ended: true,
        );
        yield paginacao;
        await paginacaoDataSource.salvarPaginacao(paginacao);
        break;
      }

      await produtosEstoqueLocalDataSource.salvarProdutos(saldo.items);

      var pagicao = Paginacao(
        key: 'estoque_sync',
        paginaAtual: paginaAtual,
        totalPaginas: saldo.meta.totalPages,
        itensPorPagina: saldo.meta.itemsPerPage,
        itensProcessadosNaPagina: saldo.meta.itemCount,
        totalItens: saldo.meta.totalItems,
        dataAtualizacao: ultimaAtualizacaoFim ?? DateTime.now(),
      );
      yield pagicao;
      await paginacaoDataSource.salvarPaginacao(pagicao);
      paginaAtual++;
    }
  }
}
