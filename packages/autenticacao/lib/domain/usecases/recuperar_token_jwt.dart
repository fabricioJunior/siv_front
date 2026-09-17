import 'package:autenticacao/domain/data/repositories/i_token_repository.dart';

class RecuperarTokenJwt {
  final ITokenRepository tokenRepository;

  RecuperarTokenJwt({required this.tokenRepository});

  Future<String?> call() async {
    final token = await tokenRepository.recuperarToken();
    return token?.jwtToken;
  }
}
