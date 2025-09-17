import 'package:autenticacao/domain/data/repositories/i_token_repository.dart';
import 'package:autenticacao/domain/data/repositories/i_usuarios_repository.dart';

class Deslogar {
  final ITokenRepository tokenRepository;
  final IUsuariosRepository usuariosRepository;

  Deslogar({
    required this.tokenRepository,
    required this.usuariosRepository,
  });

  Future<void> call() async {
    await usuariosRepository.apagarUsuarioDaSessao();
    await tokenRepository.deleteToken(notificarTokenExcluido: false);
  }
}
