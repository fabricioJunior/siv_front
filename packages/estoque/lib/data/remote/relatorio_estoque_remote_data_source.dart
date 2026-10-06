import 'package:core/remote_data_sourcers.dart';
import 'package:estoque/data/remote/dtos/relatorio_produtos_defasados_dto.dart';
import 'package:estoque/domain/data/remote/i_relatorio_estoque_remote_data_source.dart';
import 'package:estoque/data/remote/dtos/relatorio_giro_estoque_dto.dart';
import 'package:estoque/domain/models/relatorio_giro_estoque.dart';
import 'package:estoque/domain/models/relatorio_produtos_defasados.dart';

class RelatorioEstoqueRemoteDataSource extends RemoteDataSourceBase
    implements IRelatorioEstoqueRemoteDataSource {
  RelatorioEstoqueRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/relatorios/estoque{path}';

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
  }) async {
    final response = await get(
      pathParameters: {'path': '/produtos-defasados'},
      queryParameters: {
        'empresaIds': empresaIds.join(','),
        'dias': '$dias',
        'tipoMovimentacao': tipoMovimentacao,
        'visualizacao': visualizacao,
        if (dataReferencia != null) 'dataReferencia': dataReferencia,
        if (produtoIds != null && produtoIds.isNotEmpty)
          'produtoIds': produtoIds.join(','),
        if (referenciaIds != null && referenciaIds.isNotEmpty)
          'referenciaIds': referenciaIds.join(','),
        if (categoriaIds != null && categoriaIds.isNotEmpty)
          'categoriaIds': categoriaIds.join(','),
        if (corIds != null && corIds.isNotEmpty) 'corIds': corIds.join(','),
        if (tamanhoIds != null && tamanhoIds.isNotEmpty)
          'tamanhoIds': tamanhoIds.join(','),
        'modoAgrupamentoReferencia': modoAgrupamentoReferencia.name,
        if (busca != null && busca.isNotEmpty) 'busca': busca,
        'page': '$page',
        'limit': '$limit',
      },
    );
    return RelatorioProdutosDefasadosDto.fromJson(
        response.body as Map<String, dynamic>);
  }

  static String _dia(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static Map<String, String> _queryGiro(
    List<int> empresaIds,
    FiltroGiroEstoque f, {
    bool comClassificacao = true,
  }) {
    String ids(List<int> l) => l.join(',');
    final personalizado = f.periodo == PeriodoGiro.personalizado &&
        f.dataInicio != null &&
        f.dataFim != null;
    return {
      'empresaIds': ids(empresaIds),
      'periodo': personalizado ? 'personalizado' : f.periodo.api,
      if (personalizado) 'dataInicio': _dia(f.dataInicio!),
      if (personalizado) 'dataFim': _dia(f.dataFim!),
      'visualizacao': f.visualizacao,
      if (comClassificacao && f.classificacoes.isNotEmpty)
        'classificacao': f.classificacoes.map((c) => c.api).join(','),
      if (f.busca != null && f.busca!.isNotEmpty) 'busca': f.busca!,
      if (f.categoriaIds.isNotEmpty) 'categoriaIds': ids(f.categoriaIds),
      if (f.fornecedorIds.isNotEmpty) 'fornecedorIds': ids(f.fornecedorIds),
      if (f.marcaIds.isNotEmpty) 'marcaIds': ids(f.marcaIds),
      if (f.tamanhoIds.isNotEmpty) 'tamanhoIds': ids(f.tamanhoIds),
      if (f.corIds.isNotEmpty) 'corIds': ids(f.corIds),
      if (f.precoMin != null) 'precoMin': '${f.precoMin}',
      if (f.precoMax != null) 'precoMax': '${f.precoMax}',
    };
  }

  @override
  Future<PaginaGiroEstoque> giro({
    required List<int> empresaIds,
    required FiltroGiroEstoque filtro,
    required AbaGiro aba,
    required String ordenarPor,
    required String ordem,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await get(
      pathParameters: {'path': '/giro'},
      queryParameters: {
        ..._queryGiro(empresaIds, filtro),
        'aba': aba.name,
        'ordenarPor': ordenarPor,
        'ordem': ordem,
        'page': '$page',
        'limit': '$limit',
      },
    );
    return paginaGiroFromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<GiroEstoqueResumo> giroResumo({
    required List<int> empresaIds,
    required FiltroGiroEstoque filtro,
  }) async {
    final response = await get(
      pathParameters: {'path': '/giro/resumo'},
      queryParameters: _queryGiro(empresaIds, filtro, comClassificacao: false),
    );
    return giroResumoFromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<GiroEstoqueVariacoes> giroVariacoes({
    required int referenciaId,
    required List<int> empresaIds,
    required FiltroGiroEstoque filtro,
  }) async {
    final response = await get(
      pathParameters: {'path': '/giro/$referenciaId/variacoes'},
      queryParameters: _queryGiro(empresaIds, filtro),
    );
    return giroVariacoesFromJson(response.body as Map<String, dynamic>);
  }
}
