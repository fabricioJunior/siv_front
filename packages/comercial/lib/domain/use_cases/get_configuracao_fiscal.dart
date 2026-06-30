import 'package:comercial/domain/data/repositories/i_integracao_fiscal_repository.dart';
import 'package:comercial/domain/models/documento_fiscal.dart';

class GetConfiguracaoFiscal {
  final IIntegracaoFiscalRepository _repository;

  GetConfiguracaoFiscal({required IIntegracaoFiscalRepository repository})
      : _repository = repository;

  Future<({List<String> providers, EmpresaIntegracaoFiscal? config})>
      call() async {
    final providers = await _repository.listarProviders();
    final config = await _repository.getConfiguracao();
    return (providers: providers, config: config);
  }
}
