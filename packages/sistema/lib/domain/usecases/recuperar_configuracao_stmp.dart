import 'package:sistema/domain/data/repositories/i_configuracao_stmp_repository.dart';
import 'package:sistema/models.dart';

class RecuperarConfiguracaoSTMP {
  final IConfiguracaoSTMPRepository _repository;

  RecuperarConfiguracaoSTMP({
    required IConfiguracaoSTMPRepository repository,
  }) : _repository = repository;

  Future<ConfiguracaoSTMP?> call() {
    return _repository.recuperarConfiguracao();
  }
}
