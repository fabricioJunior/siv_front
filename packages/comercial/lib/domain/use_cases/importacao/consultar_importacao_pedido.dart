import 'package:comercial/domain/data/repositories/i_importacao_pedido_transferencia_repository.dart';
import 'package:comercial/domain/models/importacao_pedido_transferencia.dart';

class ConsultarImportacaoPedido {
  final IImportacaoPedidoTransferenciaRepository _repository;

  ConsultarImportacaoPedido({
    required IImportacaoPedidoTransferenciaRepository repository,
  }) : _repository = repository;

  Future<ImportacaoPedidoTransferencia> call(int id) {
    return _repository.consultarImportacao(id);
  }
}
