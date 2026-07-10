import 'package:core/remote_data_sourcers.dart';
import 'package:pagamentos/data/remote/dtos/pagamento_avulso_dto.dart';
import 'package:pagamentos/domain/data/data_sourcers/remote/i_pagamento_avulso_remote_data_source.dart';
import 'package:pagamentos/domain/models/pagamento_avulso.dart';

class PagamentoAvulsoRemoteDataSource extends RemoteDataSourceBase
    implements IPagamentoAvulsoRemoteDataSource {
  PagamentoAvulsoRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/pagamentos-avulsos{path}';

  @override
  Future<List<PagamentoAvulso>> recuperarPagamentosAvulsos({
    String? orderBy,
    String? orderDir,
    String? descricao,
    String? provider,
  }) async {
    final response = await get(
      pathParameters: {'path': ''},
      queryParameters: {
        if (orderBy != null) 'orderBy': orderBy,
        if (orderDir != null) 'orderDir': orderDir,
        if (descricao != null && descricao.isNotEmpty) 'descricao': descricao,
        if (provider != null && provider.isNotEmpty) 'provider': provider,
      },
    );
    return (response.body as List<dynamic>)
        .map(
          (json) => PagamentoAvulsoDto.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<PagamentoAvulso> criarPagamentoAvulso(
    PagamentoAvulso pagamento, {
    int? expiracaoHoras,
  }) async {
    final response = await post(
      pathParameters: {'path': ''},
      body: pagamento.toDto().toCreateJson(expiracaoHoras: expiracaoHoras),
    );
    final body = response.body as Map<String, dynamic>;
    // POST retorna { pagamento: {...}, gateway: {...} } -- o pagamento em si vem
    // aninhado, nao no nivel raiz (diferente do GET, que retorna o pagamento direto).
    return PagamentoAvulsoDto.fromJson(body['pagamento'] as Map<String, dynamic>);
  }

  @override
  Future<void> excluirPagamentoAvulso(int id) async {
    await delete(pathParameters: {'path': '/$id'});
  }

  @override
  Future<List<String>> recuperarProvidersDisponiveis() async {
    final response = await get(pathParameters: {'path': '/providers'});
    return (response.body as List<dynamic>).cast<String>();
  }
}
