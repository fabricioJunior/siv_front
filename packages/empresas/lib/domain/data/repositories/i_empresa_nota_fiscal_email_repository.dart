import 'package:empresas/domain/entities/empresa_nota_fiscal_email.dart';

abstract class IEmpresaNotaFiscalEmailRepository {
  Future<EmpresaNotaFiscalEmail> recuperarConfiguracao(int empresaId);

  Future<EmpresaNotaFiscalEmail> atualizarConfiguracao(
    EmpresaNotaFiscalEmail configuracao,
  );
}
