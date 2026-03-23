import 'dart:io';

import 'package:core/remote_data_sourcers.dart';
import 'package:produtos/data/remote/dtos/referencia_midia_dto.dart';
import 'package:produtos/domain/data/remote/i_referencia_midias_remote_data_source.dart';
import 'package:produtos/domain/models/referencia_midia.dart';

class ReferenciaMidiasRemoteDataSource extends RemoteDataSourceBase
    implements IReferenciaMidiasRemoteDataSource {
  ReferenciaMidiasRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/referencias/{referenciaId}/midias';

  @override
  Future<ReferenciaMidia> atualizarReferenciaMidia(
    ReferenciaMidia referenciaMidia,
  ) async {
    throw UnsupportedError(
      'A documentação da API de Referências - Mídias não expõe endpoint PUT para atualização.',
    );
  }

  @override
  Future<ReferenciaMidia> criarReferenciaMidia({
    required String filePath,
    required int referenciaId,
    required bool ePrincipal,
    required bool ePublica,
    required TipoReferenciaMidia tipo,
    required String field,
    required String? descricao,
  }) async {
    var pathParameters = {'referenciaId': referenciaId.toString()};
    var body = {
      'isDefault': ePrincipal,
      'isPublic': ePublica,
      'type': tipo.apiValue,
      'description': descricao,
    };
    var response = await postFile(
      field: 'midia',
      file: File(filePath),
      pathParameters: pathParameters,
      body: body,
    );

    return ReferenciaMidiaDto.fromJson(response.body);
  }

  @override
  Future<void> excluirReferenciaMidia({
    required int referenciaId,
    required int id,
  }) async {
    final uri = uriBase.replace(
      path: '/v1/referencias/$referenciaId/midias/$id',
    );
    final response = await httpClient.delete(uri: uri);
    if (response.statusCode != 204) {
      throw Exception('Erro ao excluir mídia: ${response.statusCode}');
    }
  }

  @override
  Future<List<ReferenciaMidia>> recuperarReferenciasMidias(int referenciaId) {
    var pathParameters = {'referenciaId': referenciaId.toString()};
    return get(pathParameters: pathParameters).then((response) {
      var lista = response.body as List;
      return lista
          .map((item) => ReferenciaMidiaDto.fromJson(item))
          .toList(growable: false);
    });
  }
}

extension TipoReferenciaMidiaExtension on TipoReferenciaMidia {
  String get apiValue {
    switch (this) {
      case TipoReferenciaMidia.imagem:
        return 'Imagem';
      case TipoReferenciaMidia.video:
        return 'Video';
      case TipoReferenciaMidia.documento:
        return 'Documento';
    }
  }
}
