import 'package:entregas/domain/data/repositories/i_frete_repository.dart';

class SalvarIntegracaoFrete {
  final IFreteRepository _repository;

  SalvarIntegracaoFrete({required IFreteRepository repository})
      : _repository = repository;

  Future<void> call({
    required bool ativo,
    required bool sandbox,
    required String clientId,
    String? clientSecret,
  }) =>
      _repository.salvarIntegracao(
        ativo: ativo,
        sandbox: sandbox,
        clientId: clientId,
        clientSecret: clientSecret,
      );
}
