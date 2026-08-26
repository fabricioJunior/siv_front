import 'dart:typed_data';

import 'package:comunicados/domain/data/remote/i_comunicado_remote_data_source.dart';
import 'package:comunicados/domain/models/models.dart';
import 'package:core/remote_data_sourcers.dart';

class ComunicadoRemoteDataSource extends RemoteDataSourceBase
    implements IComunicadoRemoteDataSource {
  ComunicadoRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/comunicados{path}';

  @override
  Future<int> contarDestinatarios(FiltroDestinatarioComunicado filtro) async {
    final response = await post(
      pathParameters: {'path': '/destinatarios/contar'},
      body: filtro.toBody(),
    );
    final data = response.body as Map<String, dynamic>;
    return data['total'] as int;
  }

  @override
  Future<List<PreviewDestinatarioComunicado>> previewDestinatarios(
    FiltroDestinatarioComunicado filtro, {
    int limit = 20,
  }) async {
    final queryParams = {...filtro.toQueryParams(), 'limit': limit.toString()};
    final response = await get(
      pathParameters: {'path': '/destinatarios/preview'},
      queryParameters: queryParams,
    );
    final items = response.body as List;
    return items
        .map(
          (json) => PreviewDestinatarioComunicado.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  @override
  Future<String> enviarImagem(Uint8List bytes, String fileName) async {
    final response = await postFile(
      field: 'file',
      bytes: bytes,
      fileName: fileName,
      fileType: FileType.image,
      pathParameters: {'path': '/imagens'},
    );
    final data = response.body as Map<String, dynamic>;
    return data['url'] as String;
  }

  @override
  Future<Comunicado> criar({
    required String assunto,
    required String corpoHtml,
    bool? modoHtmlAvancado,
    required FiltroDestinatarioComunicado filtro,
  }) async {
    final body = {
      'assunto': assunto,
      'corpoHtml': corpoHtml,
      if (modoHtmlAvancado != null) 'modoHtmlAvancado': modoHtmlAvancado,
      'filtro': filtro.toBody(),
    };
    final response = await post(pathParameters: {'path': ''}, body: body);
    return Comunicado.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<({List<Comunicado> items, int total})> listarComunicados({
    String? status,
    int pagina = 1,
    int itemsPorPagina = 20,
  }) async {
    final queryParams = <String, String>{
      'pagina': pagina.toString(),
      'itemsPorPagina': itemsPorPagina.toString(),
      if (status != null) 'status': status,
    };
    final response = await get(
      pathParameters: {'path': ''},
      queryParameters: queryParams,
    );
    final data = response.body as Map<String, dynamic>;
    final items = (data['items'] as List)
        .map((json) => Comunicado.fromJson(json as Map<String, dynamic>))
        .toList();
    return (items: items, total: data['total'] as int);
  }

  @override
  Future<Comunicado> buscarComunicado(int id) async {
    final response = await get(pathParameters: {'path': '/$id'});
    return Comunicado.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<({List<ComunicadoDestinatario> items, int total})>
  listarDestinatarios(
    int comunicadoId, {
    String? status,
    int pagina = 1,
    int itemsPorPagina = 20,
  }) async {
    final queryParams = <String, String>{
      'pagina': pagina.toString(),
      'itemsPorPagina': itemsPorPagina.toString(),
      if (status != null) 'status': status,
    };
    final response = await get(
      pathParameters: {'path': '/$comunicadoId/destinatarios'},
      queryParameters: queryParams,
    );
    final data = response.body as Map<String, dynamic>;
    final items = (data['items'] as List)
        .map(
          (json) =>
              ComunicadoDestinatario.fromJson(json as Map<String, dynamic>),
        )
        .toList();
    return (items: items, total: data['total'] as int);
  }

  @override
  Future<ComunicadoDestinatario> reenviarDestinatario(
    int comunicadoId,
    int destinatarioId,
  ) async {
    final response = await post(
      pathParameters: {
        'path': '/$comunicadoId/destinatarios/$destinatarioId/reenviar',
      },
      body: {},
    );
    return ComunicadoDestinatario.fromJson(
      response.body as Map<String, dynamic>,
    );
  }
}
