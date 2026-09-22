import 'package:core/remote_data_sourcers.dart';
import 'package:financeiro/data/remote/dtos/categoria_despesa_dto.dart';
import 'package:financeiro/domain/data/remote/i_categorias_despesa_remote_data_source.dart';
import 'package:financeiro/domain/models/categoria_despesa.dart';

class CategoriasDespesaRemoteDataSource extends RemoteDataSourceBase
    implements ICategoriasDespesaRemoteDataSource {
  CategoriasDespesaRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/despesas/categorias/{id}';

  @override
  Future<List<CategoriaDespesa>> recuperarCategorias({
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
        .map((json) => CategoriaDespesaDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<CategoriaDespesa?> recuperarCategoria(int id) async {
    final response = await get(pathParameters: {'id': id.toString()});
    return CategoriaDespesaDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<CategoriaDespesa> criarCategoria(CategoriaDespesa categoria) async {
    final response = await post(
      body: CategoriaDespesaDto.fromModel(categoria).toJson(),
    );
    return CategoriaDespesaDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<CategoriaDespesa> atualizarCategoria(CategoriaDespesa categoria) async {
    final response = await put(
      pathParameters: {'id': categoria.id.toString()},
      body: CategoriaDespesaDto.fromModel(categoria).toJson(),
    );
    return CategoriaDespesaDto.fromJson(response.body as Map<String, dynamic>);
  }
}
