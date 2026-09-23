import 'dart:typed_data';

import 'package:comercial/domain/models/importacao_pedido_transferencia.dart';

abstract class IImportacaoPedidoTransferenciaRemoteDataSource {
  Future<Uint8List> baixarTemplateCsv();

  Future<ImportacaoPedidoTransferencia> importarCsv({
    required String filePath,
    required int tabelaDePrecoId,
  });

  Future<ImportacaoPedidoTransferencia> consultarImportacao(int id);
}
