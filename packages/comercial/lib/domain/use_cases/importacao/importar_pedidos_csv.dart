import 'package:comercial/domain/data/repositories/i_importacao_pedido_transferencia_repository.dart';
import 'package:comercial/domain/models/importacao_pedido_transferencia.dart';

class ImportarPedidosCsv {
  final IImportacaoPedidoTransferenciaRepository _repository;

  ImportarPedidosCsv({
    required IImportacaoPedidoTransferenciaRepository repository,
  }) : _repository = repository;

  Future<ImportacaoPedidoTransferencia> call({
    required String filePath,
    required int tabelaDePrecoId,
  }) {
    return _repository.importarCsv(
      filePath: filePath,
      tabelaDePrecoId: tabelaDePrecoId,
    );
  }
}
