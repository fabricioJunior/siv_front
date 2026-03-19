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
  ) {
    // TODO: implement atualizarReferenciaMidia
    throw UnimplementedError();
  }

  @override
  Future<ReferenciaMidia> criarReferenciaMidia({
    required String filePath,
    required int referenciaId,
    required bool ePrincipal,
    required bool ePublica,
    required TipoReferenciaMidia tipo,
    required String field,
  }) async {
    var pathParameters = {'referenciaId': referenciaId.toString()};
    var body = {
      'isDefault': ePrincipal,
      'isPublic': ePublica,
      'type': tipo.apiValue,
    };
    var response = await postFile(
      field: field,
      file: File(filePath),
      pathParameters: pathParameters,
      body: body,
    );

    return ReferenciaMidiaDto.fromJson(response.body);
  }

  @override
  Future<void> excluirReferenciaMidia(int id) {
    // TODO: implement excluirReferenciaMidia
    throw UnimplementedError();
  }

  @override
  Future<List<ReferenciaMidia>> recuperarReferenciasMidias(int referenciaId) {
    // TODO: implement recuperarReferenciasMidias
    throw UnimplementedError();
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
