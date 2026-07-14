import 'package:core/remote_data_sourcers.dart';
import 'package:estoque/data/remote/dtos/historico_estoque_dto.dart';
import 'package:estoque/domain/data/remote/i_historico_estoque_remote_data_source.dart';
import 'package:estoque/domain/models/filtro_historico_estoque.dart';
import 'package:estoque/domain/models/pagina_historico_estoque.dart';

class HistoricoEstoqueRemoteDataSource extends RemoteDataSourceBase
    implements IHistoricoEstoqueRemoteDataSource {
  HistoricoEstoqueRemoteDataSource({required super.informacoesParaRequest});

  @override
  Future<PaginaHistoricoEstoque> obterHistorico({
    required FiltroHistoricoEstoque filtro,
  }) async {
    final response = await get(queryParameters: _toQueryParameters(filtro));
    return PaginaHistoricoEstoqueDto.fromJson(
      response.body as Map<String, dynamic>,
    );
  }

  Map<String, String> _toQueryParameters(FiltroHistoricoEstoque filtro) {
    return {
      if (filtro.referenciaId != null)
        'referenciaId': filtro.referenciaId.toString(),
      if (filtro.referenciaIds.isNotEmpty)
        'referenciaIds': filtro.referenciaIds.join(','),
      if (filtro.produtoId != null) 'produtoId': filtro.produtoId.toString(),
      if (filtro.produtoIds.isNotEmpty)
        'produtoIds': filtro.produtoIds.join(','),
      if (filtro.dataInicio != null)
        'dataInicio': filtro.dataInicio!.toUtc().toIso8601String(),
      if (filtro.dataFim != null)
        'dataFim': filtro.dataFim!.toUtc().toIso8601String(),
      if (filtro.operadorId != null)
        'operadorId': filtro.operadorId.toString(),
      if (filtro.funcionarioId != null)
        'funcionarioId': filtro.funcionarioId.toString(),
      if (filtro.caixaId != null) 'caixaId': filtro.caixaId.toString(),
      'page': filtro.page.toString(),
      'limit': filtro.limit.toString(),
    };
  }

  @override
  String get path => '/v1/estoque/historico';
}
