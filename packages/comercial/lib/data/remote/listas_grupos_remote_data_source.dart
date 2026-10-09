import 'dart:typed_data';

import 'package:comercial/data/remote/dtos/lista_grupo_dto.dart';
import 'package:comercial/domain/data/remote/i_listas_grupos_remote_data_source.dart';
import 'package:comercial/domain/models/lista_grupo.dart';
import 'package:core/remote_data_sourcers.dart';

class ListasGruposRemoteDataSource extends RemoteDataSourceBase
    implements IListasGruposRemoteDataSource {
  ListasGruposRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/listas-personalizadas-grupos{sufixo}';

  Map<String, dynamic> _corpo(String nome, String? descricao) => {
        'nome': nome.trim(),
        'descricao': (descricao?.trim().isEmpty ?? true) ? null : descricao!.trim(),
      };

  @override
  Future<PaginaListasGrupos> listar({int page = 1, int limit = 20}) async {
    final response = await get(
      pathParameters: const {'sufixo': ''},
      queryParameters: {'page': '$page', 'limit': '$limit'},
    );
    return ListaGrupoDto.paginaFromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<ListaGrupo> buscarPorId(int id) async {
    final response = await get(pathParameters: {'sufixo': '/$id'});
    return ListaGrupoDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<ListaGrupo> criar({required String nome, String? descricao}) async {
    final response = await post(
      pathParameters: const {'sufixo': ''},
      body: _corpo(nome, descricao),
    );
    return ListaGrupoDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<ListaGrupo> atualizar(int id, {required String nome, String? descricao}) async {
    final response = await patch(
      pathParameters: {'sufixo': '/$id'},
      body: _corpo(nome, descricao),
    );
    return ListaGrupoDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<void> excluir(int id) async {
    await delete(pathParameters: {'sufixo': '/$id'});
  }

  @override
  Future<void> definirListas(int id, List<int> listaIds) async {
    await put(
      pathParameters: {'sufixo': '/$id/listas'},
      body: ListaGrupoDto.listasToJson(listaIds),
    );
  }

  @override
  Future<ListaGrupo> enviarIcone(int id, Uint8List bytes, String fileName) async {
    final response = await postFile(
      field: 'file',
      bytes: bytes,
      fileName: fileName,
      fileType: FileType.image,
      pathParameters: {'sufixo': '/$id/icone'},
    );
    return ListaGrupoDto.fromJson(response.body as Map<String, dynamic>);
  }
}
