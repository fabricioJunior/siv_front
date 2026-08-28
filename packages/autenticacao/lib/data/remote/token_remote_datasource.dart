import 'package:autenticacao/domain/data/data_sourcers/remote/i_token_remote_data_source.dart';
import 'package:autenticacao/domain/models/token.dart';
import 'package:core/remote_data_sourcers.dart';

class TokenRemoteDatasource extends RemoteDataSourceBase
    implements ITokenRemoteDataSource {
  TokenRemoteDatasource({required super.informacoesParaRequest});

  @override
  String get path => 'v1/auth/{acao}';

  @override
  Future<Token> getToken({
    required String usuario,
    required String senha,
    required int? empresaId,
  }) async {
    var body = {
      "usuario": usuario,
      "senha": senha,
    };
    if (empresaId != null) {
      body.addAll({
        "empresaId": empresaId.toString(),
      });
    }
    var response = await post(
      body: body,
      pathParameters: {'acao': 'signIn'},
    );
    return tokenAPartirDaResponse(response, empresaId);
  }

  @override
  Future<Token?> renovarToken({
    required String refreshToken,
    required int? idEmpresa,
  }) async {
    try {
      var response = await post(
        body: {'refreshToken': refreshToken},
        pathParameters: {'acao': 'refresh'},
      );
      return tokenAPartirDaResponse(response, idEmpresa);
    } catch (_) {
      // Refresh token invalido/expirado -- quem chama decide o fallback (deslogar).
      return null;
    }
  }

  Token tokenAPartirDaResponse(
    IHttpResponse response,
    int? idEmpresa,
  ) {
    var json = response.body as Map<String, dynamic>;

    return Token(
      jwtToken: json['token'],
      dataDeCriacao: DateTime.now(),
      dataDeExpiracao: DateTime.now().add(
        const Duration(hours: 1),
      ),
      idEmpresa: idEmpresa,
      refreshToken: json['refreshToken'] as String?,
    );
  }
}

class TokenDto extends IRemoteDto implements Token {
  @override
  final String jwtToken;
  @override
  final DateTime dataDeCriacao;
  @override
  final DateTime dataDeExpiracao;

  @override
  final int? idEmpresa;

  @override
  final String? refreshToken;

  TokenDto({
    required this.jwtToken,
    required this.dataDeCriacao,
    required this.dataDeExpiracao,
    this.idEmpresa,
    this.refreshToken,
  });

  @override
  List<Object?> get props => [
        jwtToken,
      ];

  @override
  bool? get stringify => true;

  @override
  Map<String, dynamic> toJson() {
    return {};
  }
}
