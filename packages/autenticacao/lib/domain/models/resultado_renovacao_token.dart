import 'token.dart';

sealed class ResultadoRenovacaoToken {
  const ResultadoRenovacaoToken();
}

/// Refresh aceito -- [token] ja salvo localmente.
class TokenRenovado extends ResultadoRenovacaoToken {
  final Token token;
  const TokenRenovado(this.token);
}

/// Servidor recusou o refresh (ou nao ha refresh token) -- sessao perdida, deslogar.
class RenovacaoRejeitada extends ResultadoRenovacaoToken {
  const RenovacaoRejeitada();
}

/// Falha transitoria (rede, timeout, 5xx, CORS) -- manter sessao.
class RenovacaoIndisponivel extends ResultadoRenovacaoToken {
  const RenovacaoIndisponivel();
}
