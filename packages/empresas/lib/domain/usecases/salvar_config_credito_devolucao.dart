import 'package:empresas/domain/data/repositories/i_config_credito_devolucao_repository.dart';
import 'package:empresas/domain/entities/config_credito_devolucao.dart';

class SalvarConfigCreditoDevolucao {
  final IConfigCreditoDevolucaoRepository _repository;

  SalvarConfigCreditoDevolucao({
    required IConfigCreditoDevolucaoRepository repository,
  }) : _repository = repository;

  Future<ConfigCreditoDevolucao> call(
    int empresaId,
    ConfigCreditoDevolucao config,
  ) =>
      _repository.salvar(empresaId, config);
}
