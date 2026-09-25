import 'package:core/empresas_portas.dart';
import 'package:empresas/domain/usecases/recuperar_configuracao_nota_fiscal_email.dart';

class PortaVerificarPermiteNotaFiscalEmailImpl
    implements PortaVerificarPermiteNotaFiscalEmail {
  final RecuperarConfiguracaoNotaFiscalEmail
      _recuperarConfiguracaoNotaFiscalEmail;

  PortaVerificarPermiteNotaFiscalEmailImpl(
    this._recuperarConfiguracaoNotaFiscalEmail,
  );

  @override
  Future<bool> call({required int empresaId}) async {
    final configuracao =
        await _recuperarConfiguracaoNotaFiscalEmail.call(empresaId);
    return configuracao.ativo;
  }
}
