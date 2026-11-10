import 'package:core/paginacao.dart';
import 'package:estoque/domain/data/datasourcers/i_produtos_estoque_local_datasource.dart';
import 'package:estoque/estoque.dart';

/// Sobe quando o cadastro local (`ProdutoDoEstoque`) ganha coluna que o sync
/// incremental (filtra por `atualizadoEm`) não repopula sozinho.
/// v2: estampaNome.
const versaoCadastroLocalEstoque = 2;
const _chaveVersaoCadastroLocal = 'estoque_cadastro_versao';

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
    await _invalidarCadastroSeDesatualizado();
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

      final apagados = saldo.items.where((item) => item.produtoApagado);
      final vigentes = saldo.items.where((item) => !item.produtoApagado).toList();

      await produtosEstoqueLocalDataSource.salvarProdutos(vigentes);
      for (final produto in apagados) {
        await produtosEstoqueLocalDataSource.excluirProduto(produto.produtoId.toInt());
      }

      var pagicao = Paginacao(
        key: 'estoque_sync',
        paginaAtual: paginaAtual,
        totalPaginas: saldo.meta.totalPages,
        itensPorPagina: saldo.meta.itemsPerPage,
        itensProcessadosNaPagina: saldo.meta.itemCount,
        totalItens: saldo.meta.totalItems,
        dataAtualizacao: ultimaAtualizacaoFim ?? DateTime.now().toUtc(),
      );
      yield pagicao;
      await paginacaoDataSource.salvarPaginacao(pagicao);
      paginaAtual++;
    }
  }

  /// Cadastro gravado por versão antiga: apaga os produtos e zera o cursor
  /// 'estoque_sync' (força sync completo). O marcador é gravado por último:
  /// se cair no meio, a próxima sync repete a limpeza.
  Future<void> _invalidarCadastroSeDesatualizado() async {
    final marcador = await paginacaoDataSource.buscarPaginacao(_chaveVersaoCadastroLocal);
    if (marcador?.paginaAtual == versaoCadastroLocalEstoque) return;
    await produtosEstoqueLocalDataSource.excluirTodosProdutos();
    await paginacaoDataSource.salvarPaginacao(Paginacao(
      key: 'estoque_sync',
      paginaAtual: 0,
      totalPaginas: 0,
      itensPorPagina: 0,
      totalItens: 0,
      dataAtualizacao: null,
    ));
    await paginacaoDataSource.salvarPaginacao(Paginacao(
      key: _chaveVersaoCadastroLocal,
      paginaAtual: versaoCadastroLocalEstoque,
      totalPaginas: 0,
      itensPorPagina: 0,
      totalItens: 0,
      dataAtualizacao: DateTime.now().toUtc(),
      ended: true,
    ));
  }
}
