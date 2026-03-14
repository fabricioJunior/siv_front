import 'package:core/remote_data_sourcers.dart';
import 'package:pagamentos/data/remote/dtos/pagamento_avulso_dto.dart';
import 'package:pagamentos/domain/data/data_sourcers/remote/i_pagamento_avulso_remote_data_source.dart';
import 'package:pagamentos/domain/models/pagamento_avulso.dart';

class PagamentoAvulsoRemoteDataSource extends RemoteDataSourceBase
    implements IPagamentoAvulsoRemoteDataSource {
  PagamentoAvulsoRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/pagamentos-avulsos';

  @override
  Future<List<PagamentoAvulso>> recuperarPagamentosAvulsos() async {
    final response = await get();
    return (response.body as List<dynamic>)
        .map(
          (json) => PagamentoAvulsoDto.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<PagamentoAvulso> criarPagamentoAvulso(
    PagamentoAvulso pagamento,
  ) async {
    final response = await post(body: pagamento.toDto().toCreateJson());
    return PagamentoAvulsoDto.fromJson(response.body as Map<String, dynamic>);
  }
}
