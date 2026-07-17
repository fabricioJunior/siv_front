import 'package:comercial/data/remote/dtos/relatorio_dto.dart';
import 'package:comercial/domain/data/remote/i_relatorio_remote_data_source.dart';
import 'package:comercial/domain/models/relatorios.dart';
import 'package:core/remote_data_sourcers.dart';

class RelatorioRemoteDataSource extends RemoteDataSourceBase
    implements IRelatorioRemoteDataSource {
  RelatorioRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/relatorios{path}';

  @override
  Future<RelatorioFaturamento> faturamento({
    required List<int> empresaIds,
    required String dataInicial,
    required String dataFinal,
  }) async {
    final response = await get(
      pathParameters: {'path': '/faturamento/ticket-medio'},
      queryParameters: {
        'empresaIds': empresaIds.join(','),
        'dataInicial': dataInicial,
        'dataFinal': dataFinal,
      },
    );
    return RelatorioFaturamentoDto.fromJson(
        response.body as Map<String, dynamic>);
  }

  @override
  Future<RelatorioCurvaAbc> curvaAbc({
    required List<int> empresaIds,
    required String dataInicial,
    required String dataFinal,
    String? busca,
    int page = 1,
    int limit = 100,
    String agruparPor = 'produto',
  }) async {
    final response = await get(
      pathParameters: {'path': '/produtos/curva-abc'},
      queryParameters: {
        'empresaIds': empresaIds.join(','),
        'dataInicial': dataInicial,
        'dataFinal': dataFinal,
        'page': '$page',
        'limit': '$limit',
        'agruparPor': agruparPor,
        if (busca != null && busca.isNotEmpty) 'busca': busca,
      },
    );
    return RelatorioCurvaAbcDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<RelatorioClientesAtivos> clientesAtivos({
    required List<int> empresaIds,
    required int dias,
    String? dataReferencia,
    int page = 1,
    int limit = 100,
  }) async {
    final response = await get(
      pathParameters: {'path': '/clientes/ativos'},
      queryParameters: {
        'empresaIds': empresaIds.join(','),
        'dias': '$dias',
        if (dataReferencia != null) 'dataReferencia': dataReferencia,
        'page': '$page',
        'limit': '$limit',
      },
    );
    return RelatorioClientesAtivosDto.fromJson(
        response.body as Map<String, dynamic>);
  }

  @override
  Future<List<RelatorioVendasPorFuncionarioItem>> vendasPorFuncionario({
    required List<int> empresaIds,
    required List<int> funcionarioIds,
    required String dataInicial,
    required String dataFinal,
  }) async {
    final response = await get(
      pathParameters: {'path': '/faturamento/vendas-por-funcionario'},
      queryParameters: {
        'empresaIds': empresaIds.join(','),
        'funcionarioIds': funcionarioIds.join(','),
        'dataInicial': dataInicial,
        'dataFinal': dataFinal,
      },
    );
    return RelatorioVendasPorFuncionarioItemDto.listFromJson(
        response.body as Map<String, dynamic>);
  }
}
