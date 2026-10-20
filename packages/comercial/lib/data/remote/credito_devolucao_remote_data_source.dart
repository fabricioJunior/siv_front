import 'package:comercial/data/remote/dtos/credito_devolucao_dto.dart';
import 'package:comercial/data/remote/dtos/credito_devolucao_movimentacao_dto.dart';
import 'package:comercial/domain/data/remote/i_credito_devolucao_remote_data_source.dart';
import 'package:comercial/models.dart';
import 'package:core/remote_data_sourcers.dart';

class CreditoDevolucaoRemoteDataSource extends RemoteDataSourceBase
    implements ICreditoDevolucaoRemoteDataSource {
  CreditoDevolucaoRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/pessoas/{pessoaId}{sufixo}';

  static const _extrato = '/extrato/credito-de-devolucao';
  static const _creditos = '/creditos-de-devolucao';

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
      pathParameters: {'pessoaId': pessoaId, 'sufixo': _extrato},
      queryParameters: query,
    );

    final body = response.body as List<dynamic>? ?? const [];

    return body
        .whereType<Map<String, dynamic>>()
        .map(CreditoDevolucaoMovimentacaoDto.fromJson)
        .toList(growable: false);
  }

  @override
  Future<List<CreditoTransferivel>> buscarTransferiveis({
    required int pessoaId,
  }) async {
    final response = await get(
      pathParameters: {
        'pessoaId': pessoaId,
        'sufixo': '$_extrato/nao-cadastrado'
      },
    );
    final body = response.body as List<dynamic>? ?? const [];
    return body.whereType<Map<String, dynamic>>().map((j) {
      return CreditoTransferivel(
        romaneioId: _int(j['romaneioId']),
        faturaId: _int(j['faturaId']),
        faturaParcela: _int(j['faturaParcela']),
        data: DateTime.tryParse('${j['data']}') ?? DateTime.now(),
        valor: _num(j['valor']),
        observacao: (j['observacao'] ?? '').toString(),
      );
    }).toList(growable: false);
  }

  @override
  Future<ResultadoTransferenciaCredito> transferir({
    required int pessoaId,
    required List<int> romaneioIds,
  }) async {
    final response = await post(
      pathParameters: {'pessoaId': pessoaId, 'sufixo': '$_extrato/transferir'},
      body: {'romaneioIds': romaneioIds},
    );
    final j = response.body as Map<String, dynamic>;
    return ResultadoTransferenciaCredito(
      valorTotal: _num(j['valorTotal']),
      saldoCreditoDevolucaoDestino: _num(j['saldoCreditoDevolucaoDestino']),
    );
  }

  @override
  Future<List<CreditoDevolucao>> buscarCreditos({
    required int pessoaId,
    required String situacao,
  }) async {
    final response = await get(
      pathParameters: {'pessoaId': pessoaId, 'sufixo': _creditos},
      queryParameters: {'situacao': situacao},
    );
    final body = response.body as List<dynamic>? ?? const [];
    return body
        .whereType<Map<String, dynamic>>()
        .map(creditoDevolucaoDeJson)
        .toList(growable: false);
  }

  @override
  Future<ResumoCreditoDevolucao> buscarResumo({required int pessoaId}) async {
    final response = await get(
      pathParameters: {'pessoaId': pessoaId, 'sufixo': '$_creditos/resumo'},
    );
    return resumoCreditoDevolucaoDeJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<ResultadoAcaoCredito> adicionar({
    required int pessoaId,
    required double valor,
    required String motivo,
    required String observacao,
    DateTime? validade,
    int? empresaId,
  }) async {
    final response = await post(
      pathParameters: {'pessoaId': pessoaId, 'sufixo': _creditos},
      body: {
        'valor': valor,
        'motivo': motivo,
        'observacao': observacao,
        'validade': validade?.toIso8601String().split('T').first,
        if (empresaId != null) 'empresaId': empresaId,
      },
    );
    return resultadoAcaoCreditoDeJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<ResultadoAcaoCredito> remover({
    required int pessoaId,
    required int creditoId,
    double? valor,
    required String motivo,
    String? observacao,
  }) async {
    final response = await post(
      pathParameters: {
        'pessoaId': pessoaId,
        'sufixo': '$_creditos/$creditoId/remover',
      },
      body: {
        'valor': valor,
        'motivo': motivo,
        if (observacao != null && observacao.isNotEmpty)
          'observacao': observacao,
      },
    );
    return resultadoAcaoCreditoDeJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<ResultadoAcaoCredito> expirar({
    required int pessoaId,
    required int creditoId,
    String? motivo,
  }) async {
    final response = await post(
      pathParameters: {
        'pessoaId': pessoaId,
        'sufixo': '$_creditos/$creditoId/expirar',
      },
      body: {if (motivo != null && motivo.isNotEmpty) 'motivo': motivo},
    );
    return resultadoAcaoCreditoDeJson(response.body as Map<String, dynamic>);
  }

  int _int(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;

  double _num(dynamic v) =>
      v is num ? v.toDouble() : double.tryParse('$v'.replaceAll(',', '.')) ?? 0;
}
