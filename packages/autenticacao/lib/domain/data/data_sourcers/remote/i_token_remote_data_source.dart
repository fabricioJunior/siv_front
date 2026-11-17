import '../../../models/resultado_renovacao_token.dart';
import '../../../models/token.dart';

abstract class ITokenRemoteDataSource {
  Future<Token> getToken({
    required String usuario,
    required String senha,
    required int? empresaId,
  });

  // RenovacaoRejeitada: servidor recusou (400/401/403); RenovacaoIndisponivel: qualquer outra falha.
  Future<ResultadoRenovacaoToken> renovarToken({
    required String refreshToken,
    required int? idEmpresa,
  });
}
