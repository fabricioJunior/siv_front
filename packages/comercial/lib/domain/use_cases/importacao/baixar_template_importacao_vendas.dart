import 'dart:typed_data';

import 'package:comercial/domain/data/repositories/i_importacao_venda_repository.dart';

class BaixarTemplateImportacaoVendas {
  final IImportacaoVendaRepository _repository;

  BaixarTemplateImportacaoVendas({
    required IImportacaoVendaRepository repository,
  }) : _repository = repository;

  Future<Uint8List> call() {
    return _repository.baixarTemplateCsv();
  }
}
