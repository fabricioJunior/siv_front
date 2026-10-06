import 'package:estoque/domain/data/remote/i_relatorio_estoque_remote_data_source.dart';
import 'package:estoque/domain/data/repositorios/i_relatorio_estoque_repository.dart';
import 'package:estoque/domain/models/relatorio_produtos_defasados.dart';
import 'package:estoque/domain/models/relatorio_giro_estoque.dart';

class RelatorioEstoqueRepository implements IRelatorioEstoqueRepository {
  final IRelatorioEstoqueRemoteDataSource _remoteDataSource;

  RelatorioEstoqueRepository({
    required IRelatorioEstoqueRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<RelatorioProdutosDefasados> produtosDefasados({
    required List<int> empresaIds,
    int dias = 90,
    String tipoMovimentacao = 'ambas',
    String visualizacao = 'produto',
    String? dataReferencia,
    List<int>? produtoIds,
    List<int>? referenciaIds,
    List<int>? categoriaIds,
    List<int>? corIds,
    List<int>? tamanhoIds,
    ModoAgrupamentoReferencia modoAgrupamentoReferencia =
        ModoAgrupamentoReferencia.todos,
    String? busca,
    int page = 1,
    int limit = 100,
  }) =>
      _remoteDataSource.produtosDefasados(
        empresaIds: empresaIds,
        dias: dias,
        tipoMovimentacao: tipoMovimentacao,
        visualizacao: visualizacao,
        dataReferencia: dataReferencia,
        produtoIds: produtoIds,
        referenciaIds: referenciaIds,
        categoriaIds: categoriaIds,
        corIds: corIds,
        tamanhoIds: tamanhoIds,
        modoAgrupamentoReferencia: modoAgrupamentoReferencia,
        busca: busca,
        page: page,
        limit: limit,
      );

  @override
  Future<PaginaGiroEstoque> giro({
    required List<int> empresaIds,
    required FiltroGiroEstoque filtro,
    required AbaGiro aba,
    required String ordenarPor,
    required String ordem,
    int page = 1,
    int limit = 20,
  }) =>
      _remoteDataSource.giro(
        empresaIds: empresaIds,
        filtro: filtro,
        aba: aba,
        ordenarPor: ordenarPor,
        ordem: ordem,
        page: page,
        limit: limit,
      );

  @override
  Future<GiroEstoqueResumo> giroResumo({
    required List<int> empresaIds,
    required FiltroGiroEstoque filtro,
  }) =>
      _remoteDataSource.giroResumo(empresaIds: empresaIds, filtro: filtro);

  @override
  Future<GiroEstoqueVariacoes> giroVariacoes({
    required int referenciaId,
    required List<int> empresaIds,
    required FiltroGiroEstoque filtro,
  }) =>
      _remoteDataSource.giroVariacoes(
        referenciaId: referenciaId,
        empresaIds: empresaIds,
        filtro: filtro,
      );
}
