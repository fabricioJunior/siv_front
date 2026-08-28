import '../../models/token.dart';

abstract class ITokenRepository {
  Future<Token?> recuperarTokenDoServidor(
    String usuario,
    String senha,
    int? idEmpresa,
  );

  Future<Token?> recuperarToken();

  // Tenta renovar a sessao usando o refresh token salvo localmente -- se conseguir, ja salva o
  // token novo (rotacionado) e retorna. Retorna null se nao tiver refresh token salvo ou se ele
  // estiver invalido/expirado (sessao > 30 dias sem uso), quem chama decide o fallback.
  Future<Token?> renovarToken();

  Future<void> putToken(Token token);

  Future<void> deleteToken({bool notificarTokenExcluido = true});

  Stream<Token> get onTokenPut;

  Stream<Null> get onTokenDelete;
}
