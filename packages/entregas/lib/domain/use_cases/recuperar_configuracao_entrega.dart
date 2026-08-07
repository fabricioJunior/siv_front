import 'package:entregas/domain/data/repositories/i_integracao_entrega_repository.dart';
import 'package:entregas/domain/models/entrega.dart';

class RecuperarConfiguracaoEntrega {
  final IIntegracaoEntregaRepository _repository;

  RecuperarConfiguracaoEntrega({required IIntegracaoEntregaRepository repository})
      : _repository = repository;

  Future<EmpresaIntegracaoEntrega?> call() => _repository.getConfiguracao();
}
