import 'package:autenticacao/domain/data/repositories/i_token_repository.dart';
import 'package:autenticacao/domain/models/token.dart';

class CriarTokenDeAutenticacao {
  final ITokenRepository _repository;

  CriarTokenDeAutenticacao({required ITokenRepository repository})
      : _repository = repository;

  Future<Token?> call({required String usuario, required String senha}) async {
    var token = await _repository.recuperarTokenDoServidor(usuario, senha);
    if (token != null) {
      await _repository.deleteToken(notificarTokenExcluido: false);
      await _repository.putToken(token);
    }

    return token;
  }
}
