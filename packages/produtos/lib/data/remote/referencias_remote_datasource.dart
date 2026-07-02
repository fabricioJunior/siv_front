import 'package:core/remote_data_sourcers.dart';
import 'package:produtos/domain/data/remote/i_referencias_remote_data_source.dart';
import 'package:produtos/models.dart';

import 'dtos/referencia_dto.dart';

class ReferenciasRemoteDatasource extends RemoteDataSourceBase
    implements IReferenciasRemoteDataSource {
  ReferenciasRemoteDatasource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/referencias/{id}';

  @override
  Future<Referencia> fetchReferencia({required int id}) async {
    final response = await get(pathParameters: {'id': id.toString()});
    return ReferenciaDto.fromJson(response.body);
  }

  @override
  Future<Referencia> createReferencia({
    required int id,
    required String nome,
    required int categoriaId,
    int? subCategoriaId,
    String? idExterno,
    String? unidadeMedida,
    int? marcaId,
    String? descricao,
    String? composicao,
    String? cuidados,
    String? ncm,
  }) async {
    final response = await post(
      body: {
        'id': id,
        'nome': nome,
        'categoriaId': categoriaId,
        if (subCategoriaId != null) 'subCategoriaId': subCategoriaId,
        if (idExterno != null) 'idExterno': idExterno,
        if (unidadeMedida != null) 'unidadeMedida': unidadeMedida,
        if (marcaId != null) 'marcaId': marcaId,
        if (descricao != null) 'descricao': descricao,
        if (composicao != null) 'composicao': composicao,
        if (cuidados != null) 'cuidados': cuidados,
        if (ncm != null) 'ncm': ncm,
      },
    );

    return ReferenciaDto.fromJson(response.body);
  }

  @override
  Future<Referencia> atualizarReferencia({
    required int id,
    required String nome,
    required int categoriaId,
    int? subCategoriaId,
    String? idExterno,
    String? unidadeMedida,
    int? marcaId,
    String? descricao,
    String? composicao,
    String? cuidados,
    String? ncm,
  }) async {
    final response = await put(
      pathParameters: {'id': id.toString()},
      body: {
        'id': id,
        'nome': nome,
        'categoriaId': categoriaId,
        if (subCategoriaId != null) 'subCategoriaId': subCategoriaId,
        if (idExterno != null) 'idExterno': idExterno,
        if (unidadeMedida != null) 'unidadeMedida': unidadeMedida,
        if (marcaId != null) 'marcaId': marcaId,
        if (descricao != null) 'descricao': descricao,
        if (composicao != null) 'composicao': composicao,
        if (cuidados != null) 'cuidados': cuidados,
        if (ncm != null) 'ncm': ncm,
      },
    );

    return ReferenciaDto.fromJson(response.body);
  }

  @override
  Future<List<Referencia>> fetchReferencias({
    String? nome,
    bool? inativo,
  }) async {
    const limitePorPagina = 400;
    var pagina = 1;
    final referencias = <Referencia>[];
    final chavesVistas = <String>{};

    while (true) {
      final response = await get(
        queryParameters: {
          'incluir': 'tudo',
          if (nome != null && nome.isNotEmpty) 'nome': nome,
          if (inativo != null) 'inativo': inativo.toString(),
          'page': pagina.toString(),
          'limit': limitePorPagina.toString(),
        },
      );

      final body = response.body;
      final itensDaPagina = body is Map<String, dynamic>
          ? (body['items'] as List<dynamic>? ?? const <dynamic>[])
          : (body is List<dynamic> ? body : const <dynamic>[]);

      if (itensDaPagina.isEmpty) {
        break;
      }

      var adicionouNovos = false;
      for (final item in itensDaPagina) {
        if (item is! Map<String, dynamic>) {
          continue;
        }

        final referencia = ReferenciaDto.fromJson(item);
        final chave = referencia.id != null
            ? 'id:${referencia.id}'
            : 'nome:${referencia.nome.toLowerCase()}-categoria:${referencia.categoriaId}';

        if (chavesVistas.add(chave)) {
          referencias.add(referencia);
          adicionouNovos = true;
        }
      }

      if (!adicionouNovos || itensDaPagina.length < limitePorPagina) {
        break;
      }

      pagina++;
    }

    return referencias;
  }
}
