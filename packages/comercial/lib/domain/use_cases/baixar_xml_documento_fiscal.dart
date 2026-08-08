import 'dart:typed_data';

import 'package:comercial/domain/data/repositories/i_integracao_fiscal_repository.dart';

class BaixarXmlDocumentoFiscal {
  final IIntegracaoFiscalRepository _repository;

  BaixarXmlDocumentoFiscal({required IIntegracaoFiscalRepository repository})
      : _repository = repository;

  Future<Uint8List> call(int id) => _repository.baixarXml(id);
}
