import 'dart:convert';

import 'package:core/remote_data_sourcers.dart';
import 'package:financeiro/data/remote/dtos/despesa_ocorrencia_calendario_dto.dart';
import 'package:financeiro/domain/data/remote/i_despesas_calendario_remote_data_source.dart';
import 'package:financeiro/domain/models/despesa.dart';
import 'package:financeiro/domain/models/despesa_ocorrencia_calendario.dart';

class DespesasCalendarioRemoteDataSource extends RemoteDataSourceBase
    implements IDespesasCalendarioRemoteDataSource {
  DespesasCalendarioRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/despesas/calendario';

  @override
  Future<List<DespesaOcorrenciaCalendario>> recuperarCalendario({
    required int empresaId,
    required int ano,
    required int mes,
  }) async {
    final response = await get(
      queryParameters: {
        'empresaId': empresaId.toString(),
        'ano': ano.toString(),
        'mes': mes.toString(),
      },
    );

    final body = response.body as Map<String, dynamic>;
    final ocorrencias = (body['ocorrencias'] as List<dynamic>? ?? []);
    return ocorrencias
        .map(
          (json) => DespesaOcorrenciaCalendarioDto.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  @override
  Future<void> registrarOcorrencia(
    int id, {
    required int ano,
    required int mes,
    double? valor,
    DateTime? dataPagamento,
    StatusDespesa? status,
  }) async {
    // Endpoint tem path próprio (`/despesas/{id}/ocorrencias`), diferente do
    // usado por `recuperarCalendario` -- bate direto no httpClient como o
    // upload de ícone de categoria de produto já faz nesse mesmo padrão.
    await httpClient.post(
      uri: uriBase.replace(path: '/despesas/$id/ocorrencias'),
      body: jsonEncode({
        'ano': ano,
        'mes': mes,
        if (valor != null) 'valor': valor,
        if (dataPagamento != null)
          'dataPagamento': dataPagamento.toIso8601String(),
        if (status != null) 'status': status.value,
      }),
    );
  }
}
