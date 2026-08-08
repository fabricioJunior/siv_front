import 'package:comercial/domain/data/repositories/i_integracao_fiscal_repository.dart';

class ExcluirCertificadoFiscal {
  final IIntegracaoFiscalRepository _repository;

  ExcluirCertificadoFiscal({required IIntegracaoFiscalRepository repository})
      : _repository = repository;

  Future<void> call({int? empresaId}) =>
      _repository.excluirCertificadoFiscal(empresaId: empresaId);
}
