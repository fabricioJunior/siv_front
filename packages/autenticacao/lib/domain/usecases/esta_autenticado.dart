import 'package:autenticacao/domain/data/repositories/i_token_repository.dart';

class EstaAutenticado {
  final ITokenRepository tokenRepository;

  EstaAutenticado({required this.tokenRepository});
  Future<bool> call() async {
    var token = await tokenRepository.recuperarToken();
    if (token == null) {
      return false;
    }

    return token.dataDeCriacao.isBefore(DateTime.now());
  }
}
