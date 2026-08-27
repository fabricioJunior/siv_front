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

  // apagarDadosLocais=false pro caso de 401 esporádico (sessão caiu sozinha, ex: token expirou
  // com a aba em background) -- mantém produtos/estoque/preços/etc em cache, só limpa sessão/token.
  // O wipe total (apagarTodosOsDados) é só pro logout explícito do usuário, que pode trocar de
  // licenciado -- ver comentário abaixo.
  Future<void> call({bool apagarDadosLocais = true}) async {
    await licenciadosRepository.limparLicenciadoDaSessao();
    await usuariosRepository.limparTerminalDaSessao();
    await usuariosRepository.apagarUsuarioDaSessao();
    await limparCredenciaisDeAutenticacao.call();
    await tokenRepository.deleteToken(notificarTokenExcluido: false);
    if (!apagarDadosLocais) {
      return;
    }
    // Dados locais (produtos/estoque/preços/etc) não têm licenciadoId pra
    // filtrar na leitura -- sem isso, trocar de licenciado reabre o mesmo
    // banco local com dados do licenciado anterior ainda dentro.
    await localDatabaseInstance.apagarTodosOsDados();
  }
}
