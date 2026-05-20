import 'package:comercial/data/remote/dtos/credito_devolucao_movimentacao_dto.dart';
import 'package:comercial/domain/data/remote/i_credito_devolucao_remote_data_source.dart';
import 'package:comercial/models.dart';
import 'package:core/remote_data_sourcers.dart';

class CreditoDevolucaoRemoteDataSource extends RemoteDataSourceBase
    implements ICreditoDevolucaoRemoteDataSource {
  CreditoDevolucaoRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/pessoas/{pessoaId}/extrato/credito-de-devolucao';

  @override
  Future<List<CreditoDevolucaoMovimentacao>> buscarMovimentacoes({
    required int pessoaId,
    List<int>? empresaIds,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    final query = <String, String>{
      if (empresaIds != null && empresaIds.isNotEmpty)
        'empresaIds': empresaIds.join(','),
      if (dataInicio != null) 'dataInicio': dataInicio.toIso8601String(),
      if (dataFim != null) 'dataFim': dataFim.toIso8601String(),
    };

    final response = await get(
      pathParameters: {'pessoaId': pessoaId},
      queryParameters: query,
    );

    final body = response.body as List<dynamic>? ?? const [];

    return body
        .whereType<Map<String, dynamic>>()
        .map(CreditoDevolucaoMovimentacaoDto.fromJson)
        .toList(growable: false);
  }
}
