import 'package:core/remote_data_sourcers.dart';
import 'package:financeiro/data/remote/dtos/origem_pagamento_despesa_dto.dart';
import 'package:financeiro/domain/data/remote/i_origens_pagamento_despesa_remote_data_source.dart';
import 'package:financeiro/domain/models/origem_pagamento_despesa.dart';

class OrigensPagamentoDespesaRemoteDataSource extends RemoteDataSourceBase
    implements IOrigensPagamentoDespesaRemoteDataSource {
  OrigensPagamentoDespesaRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/despesas/origens-pagamento/{id}';

  @override
  Future<List<OrigemPagamentoDespesa>> recuperarOrigens({
    required int empresaId,
    String? filtro,
  }) async {
    final response = await get(
      queryParameters: {
        'empresaId': empresaId.toString(),
        if (filtro != null && filtro.trim().isNotEmpty) 'nome': filtro,
      },
    );

    return (response.body as List<dynamic>)
        .map(
          (json) =>
              OrigemPagamentoDespesaDto.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<OrigemPagamentoDespesa?> recuperarOrigem(int id) async {
    final response = await get(pathParameters: {'id': id.toString()});
    return OrigemPagamentoDespesaDto.fromJson(
      response.body as Map<String, dynamic>,
    );
  }

  @override
  Future<OrigemPagamentoDespesa> criarOrigem(
    OrigemPagamentoDespesa origem,
  ) async {
    final response = await post(
      body: OrigemPagamentoDespesaDto.fromModel(origem).toJson(),
    );
    return OrigemPagamentoDespesaDto.fromJson(
      response.body as Map<String, dynamic>,
    );
  }

  @override
  Future<OrigemPagamentoDespesa> atualizarOrigem(
    OrigemPagamentoDespesa origem,
  ) async {
    final response = await put(
      pathParameters: {'id': origem.id.toString()},
      body: OrigemPagamentoDespesaDto.fromModel(origem).toJson(),
    );
    return OrigemPagamentoDespesaDto.fromJson(
      response.body as Map<String, dynamic>,
    );
  }
}
