import 'package:core/remote_data_sourcers.dart';
import 'package:produtos/domain/data/remote/i_categorias_remote_data_source.dart';
import 'package:produtos/domain/models/categoria.dart';

import 'dtos/categoria_dto.dart';

class CategoriasRemoteDatasource extends RemoteDataSourceBase
    implements ICategoriasRemoteDataSource {
  CategoriasRemoteDatasource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/categorias/{id}';

  @override
  Future<Categoria> atualizarCategoria(int id, String nome) async {
    var response = await put(
      pathParameters: {'id': id.toString()},
      body: {'nome': nome},
    );
    return CategoriaDto.fromJson(response.body);
  }

  @override
  Future<Categoria> createCategoria(String nome) async {
    var response = await post(body: {'nome': nome});
    return CategoriaDto.fromJson(response.body);
  }

  @override
  Future<void> desativarCategoria(int id) async {
    var response = await delete(pathParameters: {'id': id.toString()});
    if (response.statusCode != 200) {
      throw Exception('Falha ao desativar categoria');
    }
  }

  @override
  Future<Categoria?> fetchCategoria(int id) async {
    var response = await get(pathParameters: {'id': id.toString()});
    return CategoriaDto.fromJson(response.body);
  }

  @override
  Future<List<Categoria>> fetchCategorias({String? nome, bool? inativa}) async {
    var response = await get(
      queryParameters: {
        if (nome != null) 'nome': nome,
        if (inativa != null) 'inativa': inativa.toString(),
      },
    );

    return (response.body as List<dynamic>)
        .map((e) => CategoriaDto.fromJson(e))
        .toList();
  }
}
