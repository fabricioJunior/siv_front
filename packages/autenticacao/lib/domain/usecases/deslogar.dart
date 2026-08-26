import 'package:autenticacao/domain/data/repositories/i_token_repository.dart';
import 'package:autenticacao/domain/data/repositories/i_licenciados_repository.dart';
import 'package:autenticacao/domain/data/repositories/i_usuarios_repository.dart';
import 'package:autenticacao/domain/usecases/limpar_credenciais_de_autenticacao.dart';
import 'package:core/local_data_sourcers/database_configs/i_local_database_instance.dart';

class Deslogar {
  final ITokenRepository tokenRepository;
  final IUsuariosRepository usuariosRepository;
  final ILicenciadosRepository licenciadosRepository;
  final LimparCredenciaisDeAutenticacao limparCredenciaisDeAutenticacao;
  final ILocalDatabaseInstance localDatabaseInstance;

  Deslogar({
    required this.tokenRepository,
    required this.usuariosRepository,
    required this.licenciadosRepository,
    required this.limparCredenciaisDeAutenticacao,
    required this.localDatabaseInstance,
  });

  Future<void> call() async {
    await licenciadosRepository.limparLicenciadoDaSessao();
    await usuariosRepository.limparTerminalDaSessao();
    await usuariosRepository.apagarUsuarioDaSessao();
    await limparCredenciaisDeAutenticacao.call();
    await tokenRepository.deleteToken(notificarTokenExcluido: false);
    // Dados locais (produtos/estoque/preços/etc) não têm licenciadoId pra
    // filtrar na leitura -- sem isso, trocar de licenciado reabre o mesmo
    // banco local com dados do licenciado anterior ainda dentro.
    await localDatabaseInstance.apagarTodosOsDados();
  }
}
