import 'package:autenticacao/domain/data/repositories/i_token_repository.dart';
import 'package:autenticacao/domain/data/repositories/i_licenciados_repository.dart';
import 'package:autenticacao/domain/data/repositories/i_usuarios_repository.dart';
import 'package:autenticacao/domain/usecases/limpar_credenciais_de_autenticacao.dart';

class Deslogar {
  final ITokenRepository tokenRepository;
  final IUsuariosRepository usuariosRepository;
  final ILicenciadosRepository licenciadosRepository;
  final LimparCredenciaisDeAutenticacao limparCredenciaisDeAutenticacao;

  Deslogar({
    required this.tokenRepository,
    required this.usuariosRepository,
    required this.licenciadosRepository,
    required this.limparCredenciaisDeAutenticacao,
  });

  Future<void> call() async {
    await licenciadosRepository.limparLicenciadoDaSessao();
    await usuariosRepository.limparTerminalDaSessao();
    await usuariosRepository.apagarUsuarioDaSessao();
    await limparCredenciaisDeAutenticacao.call();
    await tokenRepository.deleteToken(notificarTokenExcluido: false);
  }
}
