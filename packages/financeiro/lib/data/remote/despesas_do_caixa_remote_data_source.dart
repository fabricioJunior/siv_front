import 'package:core/remote_data_sourcers.dart';
import 'package:financeiro/data/remote/dtos/despesa_do_caixa_dto.dart';
import 'package:financeiro/domain/data/remote/i_despesas_do_caixa_remote_data_source.dart';
import 'package:financeiro/domain/models/despesa_do_caixa.dart';

class DespesasDoCaixaRemoteDataSource extends RemoteDataSourceBase
    implements IDespesasDoCaixaRemoteDataSource {
  DespesasDoCaixaRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/caixas/{caixaId}/despesas/{id}';

  @override
  Future<DespesaDoCaixa> criarDespesa({
    required int caixaId,
    required double valor,
    required String descricao,
    required int categoriaId,
  }) async {
    final response = await post(
      pathParameters: {'caixaId': caixaId.toString()},
      body: {
        'valor': valor,
        'descricao': descricao,
        'categoriaId': categoriaId,
      },
    );

    return DespesaDoCaixaDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<List<DespesaDoCaixa>> recuperarDespesas({
    required int caixaId,
  }) async {
    final response = await get(
      pathParameters: {'caixaId': caixaId.toString()},
    );

    if (response.statusCode == 204 || response.body is! List) {
      return [];
    }

    return (response.body as List<dynamic>)
        .map((e) => DespesaDoCaixaDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<CategoriaDespesaDoCaixa>> recuperarCategorias({
    required int caixaId,
  }) async {
    final response = await get(
      pathParameters: {'caixaId': caixaId.toString(), 'id': 'categorias'},
    );

    if (response.statusCode == 204 || response.body is! List) {
      return [];
    }

    return (response.body as List<dynamic>)
        .map(
          (e) => CategoriaDespesaDoCaixaDto.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<void> cancelarDespesa({
    required int caixaId,
    required int despesaId,
    required String motivo,
  }) async {
    await put(
      pathParameters: {
        'caixaId': caixaId.toString(),
        'id': '$despesaId/cancelar',
      },
      body: {'motivo': motivo},
    );
  }
}
