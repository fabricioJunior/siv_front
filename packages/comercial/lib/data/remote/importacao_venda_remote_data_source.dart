import 'dart:io';
import 'dart:typed_data';

import 'package:comercial/domain/data/remote/i_importacao_venda_remote_data_source.dart';
import 'package:comercial/domain/models/importacao_venda.dart';
import 'package:core/remote_data_sourcers.dart';

class ImportacaoVendaRemoteDataSource extends RemoteDataSourceBase
    implements IImportacaoVendaRemoteDataSource {
  ImportacaoVendaRemoteDataSource({required super.informacoesParaRequest});

  // Template/upload em `/v1/importacao/vendas`; status no endpoint genérico
  // `GET /v1/importacao/:id` (singular -- os outros importadores apontam pra
  // `/v1/importacoes/:id`, que não existe no backend e dá 404).
  bool _consultandoStatus = false;

  @override
  String get path => _consultandoStatus
      ? '/v1/importacao{path}'
      : '/v1/importacao/vendas{path}';

  @override
  Future<Uint8List> baixarTemplateCsv() {
    return getBytes(pathParameters: {'path': '/template'});
  }

  @override
  Future<ImportacaoVenda> importarCsv({
    required String filePath,
    required int tabelaDePrecoId,
    required int funcionarioId,
  }) async {
    final response = await postFile(
      field: 'file',
      bytes: await File(filePath).readAsBytes(),
      fileName: filePath.split(Platform.pathSeparator).last,
      fileType: FileType.other,
      pathParameters: {'path': ''},
      body: {
        'tabelaDePrecoId': tabelaDePrecoId.toString(),
        'funcionarioId': funcionarioId.toString(),
      },
    );
    return ImportacaoVenda.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<ImportacaoVenda> consultarImportacao(int id) async {
    _consultandoStatus = true;
    try {
      final response = await get(pathParameters: {'path': '/$id'});
      return ImportacaoVenda.fromJson(response.body as Map<String, dynamic>);
    } finally {
      _consultandoStatus = false;
    }
  }
}
