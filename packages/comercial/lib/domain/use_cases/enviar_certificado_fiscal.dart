import 'package:comercial/domain/data/repositories/i_integracao_fiscal_repository.dart';

class EnviarCertificadoFiscal {
  final IIntegracaoFiscalRepository _repository;

  EnviarCertificadoFiscal({required IIntegracaoFiscalRepository repository})
      : _repository = repository;

  Future<Map<String, dynamic>> call({
    required String filePath,
    required String senha,
    void Function(int sent, int total)? onSendProgress,
  }) =>
      _repository.enviarCertificadoFiscal(
        filePath: filePath,
        senha: senha,
        onSendProgress: onSendProgress,
      );
}
