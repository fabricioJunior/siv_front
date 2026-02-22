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
      },
    );

    return ReferenciaDto.fromJson(response.body);
  }

  @override
  Future<List<Referencia>> fetchReferencias({
    String? nome,
    bool? inativo,
  }) async {
    var response = await get(
      queryParameters: {
        'incluir': 'tudo',
        if (nome != null) 'nome': nome,
        if (inativo != null) 'inativo': inativo.toString(),
      },
    );

    return (response.body as List<dynamic>)
        .map((e) => ReferenciaDto.fromJson(e))
        .toList();
  }
}
