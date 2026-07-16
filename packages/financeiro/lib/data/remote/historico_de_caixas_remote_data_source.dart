import 'package:core/remote_data_sourcers.dart';
import 'package:financeiro/data/remote/dtos/caixa_do_historico_dto.dart';
import 'package:financeiro/domain/data/remote/i_historico_de_caixas_remote_data_source.dart';
import 'package:financeiro/domain/models/filtro_historico_de_caixas.dart';
import 'package:financeiro/domain/models/pagina_historico_de_caixas.dart';

class HistoricoDeCaixasRemoteDataSource extends RemoteDataSourceBase
    implements IHistoricoDeCaixasRemoteDataSource {
  HistoricoDeCaixasRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/caixas';

  @override
  Future<PaginaHistoricoDeCaixas> obterHistorico({
    required FiltroHistoricoDeCaixas filtro,
  }) async {
    final response = await get(queryParameters: _toQueryParameters(filtro));
    return PaginaHistoricoDeCaixasDto.fromJson(
      response.body as Map<String, dynamic>,
    );
  }

  Map<String, String> _toQueryParameters(FiltroHistoricoDeCaixas filtro) {
    return {
      if (filtro.terminalId != null)
        'terminalId': filtro.terminalId.toString(),
      if (filtro.operadorAberturaId != null)
        'operadorAberturaId': filtro.operadorAberturaId.toString(),
      if (filtro.situacao != null) 'situacao': filtro.situacao!.name,
      if (filtro.dataInicio != null)
        'dataInicio': _formatarData(filtro.dataInicio!),
      if (filtro.dataFim != null) 'dataFim': _formatarData(filtro.dataFim!),
      'page': filtro.page.toString(),
      'limit': filtro.limit.toString(),
    };
  }

  String _formatarData(DateTime data) {
    String dois(int v) => v.toString().padLeft(2, '0');
    return '${data.year}-${dois(data.month)}-${dois(data.day)}';
  }
}
