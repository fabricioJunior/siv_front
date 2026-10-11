import 'package:entregas/domain/data/repositories/i_frete_repository.dart';
import 'package:entregas/domain/models/frete.dart';

class RecuperarConfiguracaoFrete {
  final IFreteRepository _repository;

  RecuperarConfiguracaoFrete({required IFreteRepository repository})
      : _repository = repository;

  Future<ConfiguracaoFrete> call() => _repository.getConfiguracao();
}
