import 'package:core/remote_data_sourcers.dart';
import 'package:financeiro/data/remote/dtos/forma_de_pagamento_dto.dart';
import 'package:financeiro/domain/data/remote/i_formas_de_pagamento_remote_data_source.dart';
import 'package:financeiro/domain/models/forma_de_pagamento.dart';

class FormasDePagamentoRemoteDataSource extends RemoteDataSourceBase
    implements IFormasDePagamentoRemoteDataSource {
  FormasDePagamentoRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/formas-de-pagamento/{id}';

  @override
  Future<FormaDePagamento> atualizarFormaDePagamento(
    FormaDePagamento forma,
  ) async {
    final response = await put(
      pathParameters: {'id': forma.id.toString()},
      body: FormaDePagamentoDto.fromModel(forma).toUpdateJson(),
    );

    return FormaDePagamentoDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<FormaDePagamento> criarFormaDePagamento(FormaDePagamento forma) async {
    final response = await post(
      body: FormaDePagamentoDto.fromModel(forma).toCreateJson(),
    );

    return FormaDePagamentoDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<FormaDePagamento?> recuperarFormaDePagamento(int id) async {
    final response = await get(pathParameters: {'id': id.toString()});
    return FormaDePagamentoDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<List<FormaDePagamento>> recuperarFormasDePagamento({
    String? filtro,
  }) async {
    final response = await get(
      queryParameters: {
        if (filtro != null && filtro.trim().isNotEmpty) 'filter': filtro,
      },
    );

    return (response.body as List<dynamic>)
        .map(
          (json) => FormaDePagamentoDto.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }
}
