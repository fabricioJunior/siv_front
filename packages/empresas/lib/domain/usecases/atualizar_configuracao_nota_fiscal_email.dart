import 'package:empresas/domain/data/repositories/i_empresa_nota_fiscal_email_repository.dart';
import 'package:empresas/domain/entities/empresa_nota_fiscal_email.dart';

class AtualizarConfiguracaoNotaFiscalEmail {
  final IEmpresaNotaFiscalEmailRepository _repository;

  AtualizarConfiguracaoNotaFiscalEmail({
    required IEmpresaNotaFiscalEmailRepository repository,
  }) : _repository = repository;

  Future<EmpresaNotaFiscalEmail> call(EmpresaNotaFiscalEmail configuracao) {
    return _repository.atualizarConfiguracao(configuracao);
  }
}
