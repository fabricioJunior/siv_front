import '../../../models/token.dart';

abstract class ITokenRemoteDataSource {
  Future<Token> getToken({
    required String usuario,
    required String senha,
    required int? empresaId,
  });
}
