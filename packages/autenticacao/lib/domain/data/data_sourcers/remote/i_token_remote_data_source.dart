import '../../../models/token.dart';

abstract class ITokenRemoteDataSource {
  Future<Token> getToken({
    required String usuario,
    required String senha,
    required int? empresaId,
  });

  // Retorna null se o refresh token estiver invalido/expirado -- quem chama decide o fallback.
  Future<Token?> renovarToken({
    required String refreshToken,
    required int? idEmpresa,
  });
}
