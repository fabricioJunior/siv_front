import 'dart:convert';

import 'package:core/remote_data_sourcers.dart';
import 'package:financeiro/data/remote/dtos/despesa_dto.dart';
import 'package:financeiro/domain/data/remote/i_despesas_remote_data_source.dart';
import 'package:financeiro/domain/models/despesa.dart';
import 'package:financeiro/domain/models/pagamento_de_fatura.dart';

class DespesasRemoteDataSource extends RemoteDataSourceBase
    implements IDespesasRemoteDataSource {
  DespesasRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/despesas/{id}';

  @override
  Future<Despesa> criarDespesa(Despesa despesa) async {
    final response = await post(body: DespesaDto.fromModel(despesa).toCreateJson());
    return DespesaDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<PagamentoDeFatura> pagarFatura({
    required int empresaId,
    required int origemPagamentoId,
    required int ano,
    required int mes,
  }) async {
    // Path próprio (`/despesas/pagar-fatura`), fora do padrão `{id}` desta
    // classe -- bate direto no httpClient como o registro de ocorrência do
    // calendário já faz nesse mesmo caso.
    final response = await httpClient.patch(
      uri: uriBase.replace(path: '/v1/despesas/pagar-fatura'),
      body: jsonEncode({
        'empresaId': empresaId,
        'origemPagamentoId': origemPagamentoId,
        'ano': ano,
        'mes': mes,
      }),
    );
    final body = response.body as Map<String, dynamic>;
    return PagamentoDeFatura(
      atualizadas: (body['atualizadas'] as num).toInt(),
      valorTotal: (body['valorTotal'] as num).toDouble(),
    );
  }

  @override
  Future<Despesa> atualizarDespesa(
    int id, {
    double? valor,
    int? categoriaId,
    int? origemPagamentoId,
    DateTime? dataPagamento,
    StatusDespesa? status,
  }) async {
    final response = await put(
      pathParameters: {'id': id.toString()},
      body: {
        if (valor != null) 'valor': valor,
        if (categoriaId != null) 'categoriaId': categoriaId,
        if (origemPagamentoId != null) 'origemPagamentoId': origemPagamentoId,
        if (dataPagamento != null) 'dataPagamento': dataPagamento.toIso8601String(),
        if (status != null) 'status': status.value,
      },
    );
    return DespesaDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<List<Despesa>> recuperarDespesas({
    required int empresaId,
    int? categoriaId,
    StatusDespesa? status,
    DateTime? dataInicial,
    DateTime? dataFinal,
    bool? recorrente,
    String? grupoParcelamentoId,
  }) async {
    final response = await get(
      queryParameters: {
        'empresaId': empresaId.toString(),
        if (categoriaId != null) 'categoriaId': categoriaId.toString(),
        if (status != null) 'status': status.value,
        if (dataInicial != null)
          'dataInicial': dataInicial.toIso8601String(),
        if (dataFinal != null) 'dataFinal': dataFinal.toIso8601String(),
        if (recorrente != null) 'recorrente': recorrente.toString(),
        if (grupoParcelamentoId != null)
          'grupoParcelamentoId': grupoParcelamentoId,
      },
    );

    return (response.body as List<dynamic>)
        .map((json) => DespesaDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
