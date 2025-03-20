import 'package:autenticacao/domain/data/data_sourcers/remote/i_token_remote_data_source.dart';
import 'package:autenticacao/domain/models/token.dart';
import 'package:core/remote_data_sourcers.dart';

class TokenRemoteDatasource extends RemoteDataSourceBase
    implements ITokenRemoteDataSource {
  TokenRemoteDatasource({required super.informacoesParaRequest});

  @override
  String get path => 'v1/auth/signIn';

  @override
  Future<Token> getToken({
    required String usuario,
    required String senha,
    required int? empresaId,
  }) async {
    var body = {"usuario": usuario, "senha": senha};
    var response = await post(body: body);
    return tokenAPartirDaResponse(response);
  }

  Token tokenAPartirDaResponse(IHttpResponse response) {
    var json = response.body as Map<String, dynamic>;

    return Token(
      jwtToken: json['token'],
      dataDeCriacao: DateTime.now(),
      dataDeExpiracao: DateTime.now().add(
        const Duration(hours: 1),
      ),
    );
  }
}
