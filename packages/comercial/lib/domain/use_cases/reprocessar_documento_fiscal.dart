import 'package:comercial/domain/data/repositories/i_integracao_fiscal_repository.dart';
import 'package:comercial/domain/models/documento_fiscal.dart';

class ReprocessarDocumentoFiscal {
  final IIntegracaoFiscalRepository _repository;

  ReprocessarDocumentoFiscal({required IIntegracaoFiscalRepository repository})
      : _repository = repository;

  Future<DocumentoFiscal> call(int id) => _repository.reprocessar(id);
}
