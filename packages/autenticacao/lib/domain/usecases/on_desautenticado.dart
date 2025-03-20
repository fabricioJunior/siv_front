import 'package:autenticacao/domain/data/repositories/i_token_repository.dart';

class OnDesautenticado {
  final ITokenRepository _tokenRepository;

  OnDesautenticado({required ITokenRepository tokenRepository})
      : _tokenRepository = tokenRepository;

  Stream<Null> call() => _tokenRepository.onTokenDelete;
}
