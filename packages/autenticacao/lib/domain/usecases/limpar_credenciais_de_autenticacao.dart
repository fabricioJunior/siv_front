import 'package:autenticacao/domain/data/repositories/i_credenciais_de_autenticacao_repository.dart';

class LimparCredenciaisDeAutenticacao {
  final ICredenciaisDeAutenticacaoRepository _repository;

  LimparCredenciaisDeAutenticacao({
    required ICredenciaisDeAutenticacaoRepository repository,
  }) : _repository = repository;

  Future<void> call() {
    return _repository.limpar();
  }
}