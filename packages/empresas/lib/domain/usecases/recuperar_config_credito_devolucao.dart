import 'package:empresas/domain/data/repositories/i_config_credito_devolucao_repository.dart';
import 'package:empresas/domain/entities/config_credito_devolucao.dart';

class RecuperarConfigCreditoDevolucao {
  final IConfigCreditoDevolucaoRepository _repository;

  RecuperarConfigCreditoDevolucao({
    required IConfigCreditoDevolucaoRepository repository,
  }) : _repository = repository;

  Future<ConfigCreditoDevolucao> call(int empresaId) =>
      _repository.recuperar(empresaId);
}
