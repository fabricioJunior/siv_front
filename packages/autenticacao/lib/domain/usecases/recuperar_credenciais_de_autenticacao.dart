import 'package:autenticacao/domain/data/repositories/i_credenciais_de_autenticacao_repository.dart';
import 'package:autenticacao/domain/models/credenciais_de_autenticacao.dart';

class RecuperarCredenciaisDeAutenticacao {
  final ICredenciaisDeAutenticacaoRepository _repository;

  RecuperarCredenciaisDeAutenticacao({
    required ICredenciaisDeAutenticacaoRepository repository,
  }) : _repository = repository;

  Future<CredenciaisDeAutenticacao?> call() {
    return _repository.recuperar();
  }
}