import '../../models/resultado_renovacao_token.dart';
import '../../models/token.dart';

abstract class ITokenRepository {
  Future<Token?> recuperarTokenDoServidor(
    String usuario,
    String senha,
    int? idEmpresa,
  );

  Future<Token?> recuperarToken();

  // Renova a sessao com o refresh token salvo (single-flight: chamadas concorrentes dividem a
  // mesma renovacao). Se renovou, ja salva o token novo (rotacionado).
  Future<ResultadoRenovacaoToken> renovarToken();

  Future<void> putToken(Token token, {bool notificarTokenPut = true});

  Future<void> deleteToken({bool notificarTokenExcluido = true});

  Stream<Token> get onTokenPut;

  Stream<Null> get onTokenDelete;
}
