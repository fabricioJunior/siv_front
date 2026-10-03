import 'dart:typed_data';

import 'package:core/remote_data_sourcers.dart';
import 'package:importacao/domain/data/remote/i_importacao_remote_data_source.dart';
import 'package:importacao/domain/models/importacao_guiada.dart';

class ImportacaoRemoteDataSource extends RemoteDataSourceBase
    implements IImportacaoRemoteDataSource {
  ImportacaoRemoteDataSource({required super.informacoesParaRequest});

  // Todas as rotas de importação ficam sob `/v1/importacao`; o que muda é o
  // sufixo (`/pessoas/csv`, `/ultimas`, `/12`...).
  @override
  String get path => '/v1/importacao{path}';

  @override
  Future<List<ImportacaoGuiada>> listarUltimas() async {
    final response = await get(pathParameters: {'path': '/ultimas'});
    return (response.body as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(ImportacaoGuiada.fromJson)
        .toList(growable: false);
  }

  @override
  Future<ImportacaoGuiada> consultar(int id) async {
    final response = await get(pathParameters: {'path': '/$id'});
    return ImportacaoGuiada.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<ImportacaoPrevia> previa(
    ImportacaoEtapa etapa, {
    int? tabelaDePrecoId,
  }) async {
    final response = await get(
      pathParameters: {'path': '/previa/${etapa.name}'},
      queryParameters: tabelaDePrecoId == null
          ? null
          : {'tabelaDePrecoId': '$tabelaDePrecoId'},
    );
    return ImportacaoPrevia.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<Uint8List> baixarModelo(
    ImportacaoEtapa etapa, {
    Map<String, String> query = const {},
  }) {
    return getBytes(
      pathParameters: {'path': etapa.caminhoModelo},
      queryParameters: query.isEmpty ? null : query,
    );
  }

  @override
  Future<ImportacaoGuiada> enviar(
    ImportacaoEtapa etapa, {
    required Uint8List bytes,
    required String nomeArquivo,
    Map<String, String> parametros = const {},
  }) async {
    final response = await postFile(
      bytes: bytes,
      fileName: nomeArquivo,
      pathParameters: {'path': etapa.caminhoEnvio},
      body: parametros,
    );
    return ImportacaoGuiada.fromJson(response.body as Map<String, dynamic>);
  }
}
