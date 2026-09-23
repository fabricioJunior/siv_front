import 'dart:io';
import 'dart:typed_data';

import 'package:core/remote_data_sourcers.dart';
import 'package:produtos/domain/data/remote/i_importacao_produto_remote_data_source.dart';
import 'package:produtos/domain/models/importacao_produto.dart';

class ImportacaoProdutoRemoteDataSource extends RemoteDataSourceBase
    implements IImportacaoProdutoRemoteDataSource {
  ImportacaoProdutoRemoteDataSource({required super.informacoesParaRequest});

  // Consulta de status usa raiz diferente (`/v1/importacoes/:id`, endpoint
  // genérico) da de template/upload (`/v1/importacao/produtos`) -- mesma
  // técnica de override do datasource de promoções.
  bool _consultandoStatus = false;

  @override
  String get path => _consultandoStatus
      ? '/v1/importacoes{path}'
      : '/v1/importacao/produtos{path}';

  @override
  Future<Uint8List> baixarTemplateCsv({
    required ImportacaoProdutoVariante variante,
  }) {
    return getBytes(
      pathParameters: {'path': '/template'},
      queryParameters: {'tipo': variante.value},
    );
  }

  @override
  Future<ImportacaoProduto> importarCsv({
    required String filePath,
    required ImportacaoProdutoVariante variante,
  }) async {
    final subpath = variante == ImportacaoProdutoVariante.somente
        ? '/csv/somente'
        : '/csv';
    final response = await postFile(
      field: 'file',
      bytes: await File(filePath).readAsBytes(),
      fileName: filePath.split(Platform.pathSeparator).last,
      fileType: FileType.other,
      pathParameters: {'path': subpath},
    );
    return ImportacaoProduto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<ImportacaoProduto> consultarImportacao(int id) async {
    _consultandoStatus = true;
    try {
      final response = await get(pathParameters: {'path': '/$id'});
      return ImportacaoProduto.fromJson(
        response.body as Map<String, dynamic>,
      );
    } finally {
      _consultandoStatus = false;
    }
  }
}
