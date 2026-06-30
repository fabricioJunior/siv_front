import 'package:comercial/domain/data/repositories/i_integracao_fiscal_repository.dart';
import 'package:comercial/domain/models/documento_fiscal.dart';

class SalvarConfiguracaoFiscal {
  final IIntegracaoFiscalRepository _repository;

  SalvarConfiguracaoFiscal({required IIntegracaoFiscalRepository repository})
      : _repository = repository;

  Future<EmpresaIntegracaoFiscal> call({
    required String provider,
    required bool ativo,
    Map<String, dynamic>? configuracao,
  }) =>
      _repository.salvarConfiguracao(
        provider: provider,
        ativo: ativo,
        configuracao: configuracao,
      );
}
