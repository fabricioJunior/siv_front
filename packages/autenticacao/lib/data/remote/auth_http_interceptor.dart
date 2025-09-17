import 'dart:async';

import 'package:autenticacao/domain/data/repositories/i_token_repository.dart';
import 'package:http_interceptor/http_interceptor.dart';

class AuthHttpInterceptor extends InterceptorContract {
  final ITokenRepository tokenRepository;

  AuthHttpInterceptor(this.tokenRepository);

  @override
  FutureOr<BaseRequest> interceptRequest({required BaseRequest request}) async {
    if (request.url.toString().contains('v1/auth/signIn')) {
      return request;
    }
    var token = await tokenRepository.recuperarToken();
    request.headers['Authorization'] = 'Bearer ${token!.jwtToken}';
    return request;
  }

  @override
  FutureOr<BaseResponse> interceptResponse({
    required BaseResponse response,
  }) async {
    if (response.statusCode == 401) {
      await tokenRepository.deleteToken();
    }
    return response;
  }
}
