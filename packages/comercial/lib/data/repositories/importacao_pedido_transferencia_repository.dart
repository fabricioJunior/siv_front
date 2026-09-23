import 'dart:typed_data';

import 'package:comercial/domain/data/remote/i_importacao_pedido_transferencia_remote_data_source.dart';
import 'package:comercial/domain/data/repositories/i_importacao_pedido_transferencia_repository.dart';
import 'package:comercial/domain/models/importacao_pedido_transferencia.dart';

class ImportacaoPedidoTransferenciaRepository
    implements IImportacaoPedidoTransferenciaRepository {
  final IImportacaoPedidoTransferenciaRemoteDataSource remoteDataSource;

  ImportacaoPedidoTransferenciaRepository({required this.remoteDataSource});

  @override
  Future<Uint8List> baixarTemplateCsv() {
    return remoteDataSource.baixarTemplateCsv();
  }

  @override
  Future<ImportacaoPedidoTransferencia> importarCsv({
    required String filePath,
    required int tabelaDePrecoId,
  }) {
    return remoteDataSource.importarCsv(
      filePath: filePath,
      tabelaDePrecoId: tabelaDePrecoId,
    );
  }

  @override
  Future<ImportacaoPedidoTransferencia> consultarImportacao(int id) {
    return remoteDataSource.consultarImportacao(id);
  }
}
