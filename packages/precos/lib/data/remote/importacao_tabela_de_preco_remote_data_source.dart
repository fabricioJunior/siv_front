import 'dart:io';
import 'dart:typed_data';

import 'package:core/remote_data_sourcers.dart';
import 'package:precos/domain/data/remote/i_importacao_tabela_de_preco_remote_data_source.dart';
import 'package:precos/domain/models/importacao_tabela_de_preco.dart';

class ImportacaoTabelaDePrecoRemoteDataSource extends RemoteDataSourceBase
    implements IImportacaoTabelaDePrecoRemoteDataSource {
  ImportacaoTabelaDePrecoRemoteDataSource({
    required super.informacoesParaRequest,
  });

  // Consulta de status usa raiz diferente (`/v1/importacoes/:id`, endpoint
  // genérico) da de template/upload (`/v1/importacao/referencias/preco`) --
  // mesma técnica de override do datasource de promoções.
  bool _consultandoStatus = false;

  @override
  String get path => _consultandoStatus
      ? '/v1/importacoes{path}'
      : '/v1/importacao/referencias/preco{path}';

  @override
  Future<Uint8List> baixarTemplateCsv({required int tabelaDePrecoId}) {
    return getBytes(
      pathParameters: {'path': '/template'},
      queryParameters: {'tabelaDePrecoId': tabelaDePrecoId.toString()},
    );
  }

  @override
  Future<ImportacaoTabelaDePreco> importarCsv({required String filePath}) async {
    final response = await postFile(
      field: 'file',
      bytes: await File(filePath).readAsBytes(),
      fileName: filePath.split(Platform.pathSeparator).last,
      fileType: FileType.other,
      pathParameters: {'path': '/csv'},
    );
    return ImportacaoTabelaDePreco.fromJson(
      response.body as Map<String, dynamic>,
    );
  }

  @override
  Future<ImportacaoTabelaDePreco> consultarImportacao(int id) async {
    _consultandoStatus = true;
    try {
      final response = await get(pathParameters: {'path': '/$id'});
      return ImportacaoTabelaDePreco.fromJson(
        response.body as Map<String, dynamic>,
      );
    } finally {
      _consultandoStatus = false;
    }
  }
}
