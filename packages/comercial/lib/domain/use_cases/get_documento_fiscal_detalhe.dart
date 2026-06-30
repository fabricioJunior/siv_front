import 'package:comercial/domain/data/repositories/i_integracao_fiscal_repository.dart';
import 'package:comercial/domain/models/documento_fiscal.dart';

class GetDocumentoFiscalDetalhe {
  final IIntegracaoFiscalRepository _repository;
  GetDocumentoFiscalDetalhe(this._repository);

  Future<DocumentoFiscalDetalhe> call(int id) => _repository.getDetalhe(id);
}
