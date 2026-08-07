import 'package:entregas/domain/data/repositories/i_integracao_entrega_repository.dart';
import 'package:entregas/domain/models/entrega.dart';

class SalvarConfiguracaoEntrega {
  final IIntegracaoEntregaRepository _repository;

  SalvarConfiguracaoEntrega({required IIntegracaoEntregaRepository repository})
      : _repository = repository;

  Future<EmpresaIntegracaoEntrega> call({
    required String provider,
    bool? ativo,
    Map<String, dynamic>? configuracao,
  }) =>
      _repository.salvarConfiguracao(
        provider: provider,
        ativo: ativo,
        configuracao: configuracao,
      );
}
