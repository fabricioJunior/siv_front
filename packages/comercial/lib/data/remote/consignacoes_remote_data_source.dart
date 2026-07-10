import 'package:comercial/data/remote/dtos/consignacao_dto.dart';
import 'package:comercial/domain/data/remote/i_consignacoes_remote_data_source.dart';
import 'package:comercial/models.dart';
import 'package:core/remote_data_sourcers.dart';

class ConsignacoesRemoteDataSource extends RemoteDataSourceBase
    implements IConsignacoesRemoteDataSource {
  ConsignacoesRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/consignacoes/{id}';

  @override
  Future<List<Consignacao>> buscarPorFiltro({
    List<int>? empresaIds,
    List<int>? pessoaIds,
    List<int>? funcionarioIds,
    List<SituacaoConsignacao>? situacoes,
    bool incluirItens = false,
  }) async {
    final response = await post(
      body: {
        if (empresaIds != null && empresaIds.isNotEmpty)
          'empresaIds': empresaIds,
        if (pessoaIds != null && pessoaIds.isNotEmpty) 'pessoaIds': pessoaIds,
        if (funcionarioIds != null && funcionarioIds.isNotEmpty)
          'funcionarioIds': funcionarioIds,
        if (situacoes != null && situacoes.isNotEmpty)
          'situacoes': situacoes.map((s) => s.toJsonValue()).toList(),
        if (incluirItens) 'incluir': ['itens'],
      },
    );

    final body = response.body as List<dynamic>? ?? const [];
    return body
        .map((json) => ConsignacaoDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Consignacao> abrir({
    required int pessoaId,
    required int funcionarioId,
    required int tabelaPrecoId,
    required int caixaAbertura,
    String? observacao,
  }) async {
    final response = await post(
      pathParameters: {'id': 'abrir'},
      body: {
        'pessoaId': pessoaId,
        'funcionarioId': funcionarioId,
        'tabelaPrecoId': tabelaPrecoId,
        'caixaAbertura': caixaAbertura,
        if (observacao != null && observacao.trim().isNotEmpty)
          'observacao': observacao,
      },
    );
    return ConsignacaoDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<Consignacao> buscarPorId(int id, {bool incluirItens = false}) async {
    final response = await get(
      pathParameters: {'id': '$id'},
      queryParameters: incluirItens ? {'incluir': 'itens'} : null,
    );
    return ConsignacaoDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<Consignacao> atualizar({
    required int id,
    int? funcionarioId,
    String? observacao,
  }) async {
    final response = await put(
      pathParameters: {'id': '$id/atualizar'},
      body: {
        if (funcionarioId != null) 'funcionarioId': funcionarioId,
        if (observacao != null) 'observacao': observacao,
      },
    );
    return ConsignacaoDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<void> recalcular(int id) async {
    await put(pathParameters: {'id': '$id/recalcular'}, body: const {});
  }

  @override
  Future<void> fechar(int id) async {
    await post(pathParameters: {'id': '$id/fechar'}, body: const {});
  }

  @override
  Future<void> cancelar({
    required int id,
    required String motivoCancelamento,
  }) async {
    await post(
      pathParameters: {'id': '$id/cancelar'},
      body: {'motivoCancelamento': motivoCancelamento},
    );
  }
}
