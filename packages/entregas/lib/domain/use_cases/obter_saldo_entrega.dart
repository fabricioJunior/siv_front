import 'package:entregas/domain/data/repositories/i_integracao_entrega_repository.dart';

class ObterSaldoEntrega {
  final IIntegracaoEntregaRepository _repository;

  ObterSaldoEntrega({required IIntegracaoEntregaRepository repository})
      : _repository = repository;

  Future<double> call() => _repository.getSaldo();
}
