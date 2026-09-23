import 'dart:typed_data';

import 'package:comercial/domain/data/repositories/i_importacao_pedido_transferencia_repository.dart';

class BaixarTemplateImportacaoPedidos {
  final IImportacaoPedidoTransferenciaRepository _repository;

  BaixarTemplateImportacaoPedidos({
    required IImportacaoPedidoTransferenciaRepository repository,
  }) : _repository = repository;

  Future<Uint8List> call() {
    return _repository.baixarTemplateCsv();
  }
}
