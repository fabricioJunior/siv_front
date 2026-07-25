import 'package:empresas/domain/data/remote_data_sourcers/i_empresa_nota_fiscal_email_remote_data_source.dart';
import 'package:empresas/domain/data/repositories/i_empresa_nota_fiscal_email_repository.dart';
import 'package:empresas/domain/entities/empresa_nota_fiscal_email.dart';

class EmpresaNotaFiscalEmailRepository
    implements IEmpresaNotaFiscalEmailRepository {
  final IEmpresaNotaFiscalEmailRemoteDataSource remoteDataSource;

  EmpresaNotaFiscalEmailRepository({required this.remoteDataSource});

  @override
  Future<EmpresaNotaFiscalEmail> recuperarConfiguracao(int empresaId) {
    return remoteDataSource.recuperarConfiguracao(empresaId);
  }

  @override
  Future<EmpresaNotaFiscalEmail> atualizarConfiguracao(
    EmpresaNotaFiscalEmail configuracao,
  ) {
    return remoteDataSource.atualizarConfiguracao(configuracao);
  }
}
