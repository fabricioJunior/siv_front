import 'dart:io';
import 'dart:typed_data';

import 'package:comercial/domain/data/remote/i_importacao_pedido_transferencia_remote_data_source.dart';
import 'package:comercial/domain/models/importacao_pedido_transferencia.dart';
import 'package:core/remote_data_sourcers.dart';

class ImportacaoPedidoTransferenciaRemoteDataSource extends RemoteDataSourceBase
    implements IImportacaoPedidoTransferenciaRemoteDataSource {
  ImportacaoPedidoTransferenciaRemoteDataSource({
    required super.informacoesParaRequest,
  });

  // Consulta de status usa raiz diferente (`/v1/importacoes/:id`, endpoint
  // genérico) da de template/upload (`/v1/importacao/pedidos/transferencia/entrada`)
  // -- mesma técnica de override do datasource de promoções.
  bool _consultandoStatus = false;

  @override
  String get path => _consultandoStatus
      ? '/v1/importacoes{path}'
      : '/v1/importacao/pedidos/transferencia/entrada{path}';

  @override
  Future<Uint8List> baixarTemplateCsv() {
    return getBytes(pathParameters: {'path': '/template'});
  }

  @override
  Future<ImportacaoPedidoTransferencia> importarCsv({
    required String filePath,
    required int tabelaDePrecoId,
  }) async {
    final response = await postFile(
      field: 'file',
      bytes: await File(filePath).readAsBytes(),
      fileName: filePath.split(Platform.pathSeparator).last,
      fileType: FileType.other,
      pathParameters: {'path': ''},
      body: {'tabelaDePrecoId': tabelaDePrecoId.toString()},
    );
    return ImportacaoPedidoTransferencia.fromJson(
      response.body as Map<String, dynamic>,
    );
  }

  @override
  Future<ImportacaoPedidoTransferencia> consultarImportacao(int id) async {
    _consultandoStatus = true;
    try {
      final response = await get(pathParameters: {'path': '/$id'});
      return ImportacaoPedidoTransferencia.fromJson(
        response.body as Map<String, dynamic>,
      );
    } finally {
      _consultandoStatus = false;
    }
  }
}
