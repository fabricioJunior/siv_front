import 'package:entregas/domain/data/repositories/i_frete_repository.dart';

class ObterUrlAutorizacaoFrete {
  final IFreteRepository _repository;

  ObterUrlAutorizacaoFrete({required IFreteRepository repository})
      : _repository = repository;

  Future<String> call() => _repository.getUrlAutorizacao();
}
