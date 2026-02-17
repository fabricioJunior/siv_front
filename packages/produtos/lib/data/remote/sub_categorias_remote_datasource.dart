import 'package:core/remote_data_sourcers.dart';
import 'package:produtos/domain/data/remote/i_sub_categorias_remote_data_source.dart';
import 'package:produtos/domain/models/sub_categoria.dart';

import 'dtos/sub_categoria_dto.dart';

class SubCategoriasRemoteDatasource extends RemoteDataSourceBase
    implements ISubCategoriasRemoteDataSource {
  SubCategoriasRemoteDatasource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/categorias/{categoriaId}/sub/{id}';

  @override
  Future<SubCategoria> atualizarSubCategoria(
    int categoriaId,
    int id,
    String nome,
  ) async {
    var response = await put(
      pathParameters: {
        'categoriaId': categoriaId.toString(),
        'id': id.toString(),
      },
      body: {'nome': nome},
    );
    return SubCategoriaDto.fromJson(response.body);
  }

  @override
  Future<SubCategoria> createSubCategoria(int categoriaId, String nome) async {
    var response = await post(
      pathParameters: {'categoriaId': categoriaId.toString()},
      body: {'nome': nome},
    );
    return SubCategoriaDto.fromJson(response.body);
  }

  @override
  Future<void> desativarSubCategoria(int categoriaId, int id) async {
    var response = await delete(
      pathParameters: {
        'categoriaId': categoriaId.toString(),
        'id': id.toString(),
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Falha ao desativar sub-categoria');
    }
  }

  @override
  Future<SubCategoria?> fetchSubCategoria(int categoriaId, int id) async {
    var response = await get(
      pathParameters: {
        'categoriaId': categoriaId.toString(),
        'id': id.toString(),
      },
    );
    return SubCategoriaDto.fromJson(response.body);
  }

  @override
  Future<List<SubCategoria>> fetchSubCategorias(
    int categoriaId, {
    String? nome,
    bool? inativa,
  }) async {
    var response = await get(
      pathParameters: {'categoriaId': categoriaId.toString()},
      queryParameters: {
        if (nome != null) 'nome': nome,
        if (inativa != null) 'inativa': inativa.toString(),
      },
    );

    return (response.body as List<dynamic>)
        .map((e) => SubCategoriaDto.fromJson(e))
        .toList();
  }
}
