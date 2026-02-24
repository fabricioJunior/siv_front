import 'package:sistema/domain/data/repositories/i_configuracao_stmp_repository.dart';

class VerificarConexaoSTMP {
  final IConfiguracaoSTMPRepository _repository;

  VerificarConexaoSTMP({
    required IConfiguracaoSTMPRepository repository,
  }) : _repository = repository;

  Future<bool> call() {
    return _repository.verificarConexao();
  }
}
