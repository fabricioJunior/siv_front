import '../../models/token.dart';

abstract class ITokenRepository {
  Future<Token?> recuperarTokenDoServidor(
    String usuario,
    String senha,
  );

  Future<Token?> recuperarToken();

  Future<void> putToken(Token token);

  Future<void> deleteToken();

  Stream<Token> get onTokenPut;

  Stream<Null> get onTokenDelete;
}
