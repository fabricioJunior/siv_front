import 'dart:typed_data';

import 'package:comercial/data/remote/dtos/lista_personalizada_dto.dart';
import 'package:comercial/data/remote/dtos/lista_personalizada_resumo_dto.dart';
import 'package:comercial/domain/data/remote/i_lista_personalizada_remote_data_source.dart';
import 'package:comercial/domain/models/lista_personalizada.dart';
import 'package:comercial/domain/models/lista_personalizada_resumo.dart';
import 'package:core/remote_data_sourcers.dart';

class ListaPersonalizadaRemoteDataSource extends RemoteDataSourceBase
    implements IListaPersonalizadaRemoteDataSource {
  ListaPersonalizadaRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/listas-personalizadas{sufixo}';

  @override
  Future<ListaPersonalizada> criar(ListaPersonalizadaInput input) async {
    final response = await post(
      pathParameters: const {'sufixo': ''},
      body: ListaPersonalizadaDto.inputToJson(input),
    );
    return ListaPersonalizadaDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<ListaPersonalizada> atualizar(
    int id,
    ListaPersonalizadaInput input,
  ) async {
    final response = await patch(
      pathParameters: {'sufixo': '/$id'},
      body: ListaPersonalizadaDto.inputToJson(input, incluirNulos: true),
    );
    return ListaPersonalizadaDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<ListaPersonalizada> atualizarTitulo(int id, String? titulo) async {
    final response = await patch(
      pathParameters: {'sufixo': '/$id'},
      body: {'titulo': titulo},
    );
    return ListaPersonalizadaDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<ListaPersonalizada> adicionarItens(int id, List<int> referenciaIds) async {
    final response = await post(
      pathParameters: {'sufixo': '/$id/itens'},
      body: {'referenciaIds': referenciaIds},
    );
    return ListaPersonalizadaDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<ListaPersonalizada> removerItens(int id, List<int> referenciaIds) async {
    final response = await delete(
      pathParameters: {'sufixo': '/$id/itens'},
      body: {'referenciaIds': referenciaIds},
    );
    return ListaPersonalizadaDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<ListaPersonalizada> buscarPorId(int id) async {
    final response = await get(pathParameters: {'sufixo': '/$id'});
    return ListaPersonalizadaDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<String> buscarLink(int id) async {
    final response = await get(pathParameters: {'sufixo': '/$id/link'});
    final body = response.body as Map<String, dynamic>;
    return body['url']?.toString() ?? '';
  }

  @override
  Future<ListaItensLoteResultado> adicionarPorFiltro(
    int id,
    ListaItensLote lote,
  ) async {
    final response = await post(
      pathParameters: {'sufixo': '/$id/itens/por-filtro'},
      body: ListaPersonalizadaDto.loteToJson(lote),
    );
    final body = response.body as Map<String, dynamic>;
    return ListaItensLoteResultado(
      adicionadas: int.tryParse(body['adicionadas']?.toString() ?? '') ?? 0,
      total: int.tryParse(body['total']?.toString() ?? '') ?? 0,
    );
  }

  @override
  Future<ListaPersonalizada> enviarIcone(
    int id,
    Uint8List bytes,
    String fileName,
  ) async {
    final response = await postFile(
      field: 'file',
      bytes: bytes,
      fileName: fileName,
      fileType: FileType.image,
      pathParameters: {'sufixo': '/$id/icone'},
    );
    return ListaPersonalizadaDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<ListaPrevia> previa(int id, {int page = 1, int limit = 20}) async {
    final response = await get(
      pathParameters: {'sufixo': '/$id/previa'},
      queryParameters: {'page': '$page', 'limit': '$limit'},
    );
    return ListaPreviaDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<PaginaListasPersonalizadas> listar({
    int page = 1,
    int limit = 20,
    ListaTipo? tipo,
  }) async {
    final response = await get(
      pathParameters: const {'sufixo': ''},
      queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
        if (tipo != null) 'tipo': tipo.name,
      },
    );
    return PaginaListasPersonalizadasDto.fromJson(response.body as Map<String, dynamic>);
  }
}
