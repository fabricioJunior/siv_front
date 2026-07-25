import 'package:empresas/domain/data/repositories/i_empresa_nota_fiscal_email_repository.dart';
import 'package:empresas/domain/entities/empresa_nota_fiscal_email.dart';

class RecuperarConfiguracaoNotaFiscalEmail {
  final IEmpresaNotaFiscalEmailRepository _repository;

  RecuperarConfiguracaoNotaFiscalEmail({
    required IEmpresaNotaFiscalEmailRepository repository,
  }) : _repository = repository;

  Future<EmpresaNotaFiscalEmail> call(int empresaId) {
    return _repository.recuperarConfiguracao(empresaId);
  }
}
