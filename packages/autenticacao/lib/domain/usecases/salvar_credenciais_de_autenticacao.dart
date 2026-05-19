import 'package:autenticacao/domain/data/repositories/i_credenciais_de_autenticacao_repository.dart';
import 'package:autenticacao/domain/models/credenciais_de_autenticacao.dart';

class SalvarCredenciaisDeAutenticacao {
  final ICredenciaisDeAutenticacaoRepository _repository;

  SalvarCredenciaisDeAutenticacao({
    required ICredenciaisDeAutenticacaoRepository repository,
  }) : _repository = repository;

  Future<void> call({required String usuario, required String senha}) {
    return _repository.salvar(
      CredenciaisDeAutenticacao(usuario: usuario, senha: senha),
    );
  }
}