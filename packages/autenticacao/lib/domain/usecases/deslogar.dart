import 'package:autenticacao/domain/data/repositories/i_token_repository.dart';
import 'package:autenticacao/domain/data/repositories/i_licenciados_repository.dart';
import 'package:autenticacao/domain/data/repositories/i_usuarios_repository.dart';

class Deslogar {
  final ITokenRepository tokenRepository;
  final IUsuariosRepository usuariosRepository;
  final ILicenciadosRepository licenciadosRepository;

  Deslogar({
    required this.tokenRepository,
    required this.usuariosRepository,
    required this.licenciadosRepository,
  });

  Future<void> call() async {
    await licenciadosRepository.limparLicenciadoDaSessao();
    await usuariosRepository.apagarUsuarioDaSessao();
    await tokenRepository.deleteToken(notificarTokenExcluido: false);
  }
}
