import 'package:core/remote_data_sourcers.dart';
import 'package:pessoas/data/remote/dtos/pessoa_extrato_movimentacao_dto.dart';
import 'package:pessoas/domain/data/data_sourcers/remote/i_pessoa_extrato_remote_data_source.dart';
import 'package:pessoas/domain/models/pessoa_extrato_movimentacao.dart';

class PessoaExtratoRemoteDataSource extends RemoteDataSourceBase
    implements IPessoaExtratoRemoteDataSource {
  PessoaExtratoRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => 'v1/pessoas/{id}/extrato';

  @override
  Future<List<PessoaExtratoMovimentacao>> buscarExtrato({
    required int pessoaId,
    List<int>? empresaIds,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    final response = await get(
      pathParameters: {'id': '$pessoaId'},
      queryParameters: {
        if (empresaIds != null && empresaIds.isNotEmpty)
          'empresaIds': empresaIds.join(','),
        if (dataInicio != null) 'dataInicio': dataInicio.toIso8601String(),
        if (dataFim != null) 'dataFim': dataFim.toIso8601String(),
      },
    );

    final body = response.body as List<dynamic>? ?? const [];
    return body
        .map(
          (json) => PessoaExtratoMovimentacaoDto.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}
