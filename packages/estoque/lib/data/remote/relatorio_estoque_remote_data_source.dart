import 'package:core/remote_data_sourcers.dart';
import 'package:estoque/data/remote/dtos/relatorio_produtos_defasados_dto.dart';
import 'package:estoque/domain/data/remote/i_relatorio_estoque_remote_data_source.dart';
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
}
