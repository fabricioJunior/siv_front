import 'dart:async';

import 'package:autenticacao/domain/data/repositories/i_token_repository.dart';
import 'package:autenticacao/domain/models/token.dart';

class OnAutenticado {
  final ITokenRepository tokenRepository;

  OnAutenticado({required this.tokenRepository});

  Stream<Token> call() {
    StreamTransformer<Token, Token> regraAutenticacaoTransformer =
        StreamTransformer.fromHandlers(handleData: onTokenPut);

    return tokenRepository.onTokenPut.transform(regraAutenticacaoTransformer);
  }

  Token? lastToken;
  void onTokenPut(Token token, EventSink<dynamic> sink) {
    if (lastToken == null) {
      sink.add(token);
    }
  }
}
