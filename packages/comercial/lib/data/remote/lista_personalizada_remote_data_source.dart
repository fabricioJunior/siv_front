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
  Future<ListaPersonalizada> criar({
    required int tabelaPrecoId,
    required DateTime dataExpiracao,
    List<int> referenciaIds = const [],
  }) async {
    final response = await post(
      pathParameters: const {'sufixo': ''},
      body: {
        'tabelaPrecoId': tabelaPrecoId,
        'dataExpiracao': dataExpiracao.toIso8601String(),
        if (referenciaIds.isNotEmpty) 'referenciaIds': referenciaIds,
      },
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
  Future<PaginaListasPersonalizadas> listar({int page = 1, int limit = 20}) async {
    final response = await get(
      pathParameters: const {'sufixo': ''},
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
    );
    return PaginaListasPersonalizadasDto.fromJson(response.body as Map<String, dynamic>);
  }
}
