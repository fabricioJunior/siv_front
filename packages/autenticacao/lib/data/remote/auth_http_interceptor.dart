import 'dart:async';
import 'dart:developer';

import 'package:autenticacao/domain/data/repositories/i_token_repository.dart';
import 'package:autenticacao/domain/models/resultado_renovacao_token.dart';
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
    final token = await tokenRepository.recuperarToken();
    // Sem token segue sem header: o 401 resultante cai no fluxo normal.
    if (token != null) {
      request.headers['Authorization'] = 'Bearer ${token.jwtToken}';
    }
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
    if (requisicaoOriginal == null) {
      await _deslogar('401 sem requisicao original');
      return response;
    }
    if (_ehRotaDeAuth(requisicaoOriginal.url)) {
      // 401 do /refresh e' tratado por quem chamou (RenovacaoRejeitada); signIn 401 limpa token.
      if (!requisicaoOriginal.url.toString().contains('v1/auth/refresh')) {
        await _deslogar('rota de auth 401: ${requisicaoOriginal.url.path}');
      }
      return response;
    }

    // Outra requisicao ja pode ter renovado: se o token mudou desde que esta foi enviada,
    // reenvia com o atual sem novo refresh.
    final enviado = requisicaoOriginal.headers['Authorization'];
    var atual = await tokenRepository.recuperarToken();
    if (atual == null || enviado == 'Bearer ${atual.jwtToken}') {
      final resultado = await tokenRepository.renovarToken();
      switch (resultado) {
        case RenovacaoRejeitada():
          await _deslogar('refresh rejeitado pelo servidor');
          return response;
        case RenovacaoIndisponivel():
          log('refresh indisponivel (falha transitoria), sessao mantida');
          return response;
        case TokenRenovado(:final token):
          atual = token;
      }
    }

    // So reenvia Request (JSON simples) -- multipart/streamed (upload) devolve o 401 e o
    // usuario repete o envio ja com o token novo, sem deslogar.
    if (requisicaoOriginal is! http.Request) {
      return response;
    }

    final requisicaoRenovada = http.Request(
      requisicaoOriginal.method,
      requisicaoOriginal.url,
    )
      ..headers.addAll(requisicaoOriginal.headers)
      ..headers['Authorization'] = 'Bearer ${atual.jwtToken}'
      ..bodyBytes = requisicaoOriginal.bodyBytes;

    return http.Response.fromStream(
      await http.Client().send(requisicaoRenovada),
    );
  }

  Future<void> _deslogar(String motivo) {
    log('token apagado: $motivo', name: 'AuthHttpInterceptor');
    return tokenRepository.deleteToken();
  }

  bool _ehRotaDeAuth(Uri url) {
    final path = url.toString();
    return path.contains('v1/auth/signIn') || path.contains('v1/auth/refresh');
  }
}
