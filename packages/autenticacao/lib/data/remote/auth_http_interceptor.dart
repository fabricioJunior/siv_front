import 'dart:async';

import 'package:autenticacao/domain/data/repositories/i_token_repository.dart';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';

class AuthHttpInterceptor extends InterceptorContract {
  final ITokenRepository tokenRepository;

  AuthHttpInterceptor(this.tokenRepository);

  @override
  FutureOr<BaseRequest> interceptRequest({required BaseRequest request}) async {
    if (_ehRotaDeAuth(request.url)) {
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
    if (response.statusCode != 401) {
      return response;
    }

    final requisicaoOriginal = response.request;
    // Sem requisicao pra repetir, ou o proprio /refresh que falhou -- nao ha o que tentar de
    // novo, cai direto no fallback de deslogar.
    if (requisicaoOriginal == null || _ehRotaDeAuth(requisicaoOriginal.url)) {
      await tokenRepository.deleteToken();
      return response;
    }

    final tokenRenovado = await tokenRepository.renovarToken();
    if (tokenRenovado == null) {
      await tokenRepository.deleteToken();
      return response;
    }

    // So sabe reconstruir e reenviar requisicoes JSON simples (Request) -- multipart/streamed
    // (upload de foto/CSV) fica fora do retry automatico, cai no fallback de deslogar. Raro no
    // app e o usuario so precisa repetir a acao manualmente apos relogar.
    if (requisicaoOriginal is! http.Request) {
      await tokenRepository.deleteToken();
      return response;
    }

    final requisicaoRenovada = http.Request(
      requisicaoOriginal.method,
      requisicaoOriginal.url,
    )
      ..headers.addAll(requisicaoOriginal.headers)
      ..headers['Authorization'] = 'Bearer ${tokenRenovado.jwtToken}'
      ..bodyBytes = requisicaoOriginal.bodyBytes;

    return http.Response.fromStream(
      await http.Client().send(requisicaoRenovada),
    );
  }

  bool _ehRotaDeAuth(Uri url) {
    final path = url.toString();
    return path.contains('v1/auth/signIn') || path.contains('v1/auth/refresh');
  }
}
