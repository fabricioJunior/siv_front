import 'dart:async';

import 'package:autenticacao/domain/data/data_sourcers/local/i_token_local_data_source.dart';
import 'package:autenticacao/domain/data/data_sourcers/remote/i_token_remote_data_source.dart';
import 'package:autenticacao/domain/data/repositories/i_token_repository.dart';
import 'package:autenticacao/domain/models/resultado_renovacao_token.dart';
import 'package:autenticacao/domain/models/token.dart';

class TokenRepository implements ITokenRepository {
  final ITokenLocalDataSource<Token> localDataSource;
  final ITokenRemoteDataSource remoteDataSource;

  final StreamController<Token> _onTokenPut = StreamController.broadcast();

  final StreamController<Null> _onDeleteToken = StreamController.broadcast();

  Future<ResultadoRenovacaoToken>? _renovando;
  // Token novo durante a troca (delete+put): evita janela em que recuperarToken devolve null.
  Token? _tokenEmTroca;

  TokenRepository({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<void> putToken(Token token, {bool notificarTokenPut = true}) async {
    await localDataSource.put(token);
    if (notificarTokenPut) {
      _onTokenPut.add(token);
    }
  }

  @override
  Future<Token?> recuperarToken() async {
    if (_tokenEmTroca != null) return _tokenEmTroca;
    var tokens = await localDataSource.fetchAll();

    return tokens.isEmpty ? null : tokens.first;
  }

  @override
  Future<ResultadoRenovacaoToken> renovarToken() {
    return _renovando ??=
        _renovar().whenComplete(() => _renovando = null);
  }

  Future<ResultadoRenovacaoToken> _renovar() async {
    var tokenAtual = await recuperarToken();
    if (tokenAtual?.refreshToken == null) {
      return const RenovacaoRejeitada();
    }

    var resultado = await remoteDataSource.renovarToken(
      refreshToken: tokenAtual!.refreshToken!,
      idEmpresa: tokenAtual.idEmpresa,
    );
    if (resultado is! TokenRenovado) {
      return resultado;
    }

    // dataBaseId da box e' hash do jwtToken (muda a cada renovacao) -- sem apagar antes, cada
    // refresh acumularia uma entrada nova na box em vez de substituir.
    // notificarTokenPut: false -- renovação é silenciosa (sessão já autenticada); notificar
    // reemitiria AppAutenticou no meio da sessão.
    _tokenEmTroca = resultado.token;
    try {
      await deleteToken(notificarTokenExcluido: false);
      await putToken(resultado.token, notificarTokenPut: false);
    } finally {
      _tokenEmTroca = null;
    }
    return resultado;
  }

  @override
  Future<Token?> recuperarTokenDoServidor(
    String usuario,
    String senha,
    int? idEmpresa,
  ) {
    return remoteDataSource.getToken(
      usuario: usuario,
      senha: senha,
      empresaId: idEmpresa,
    );
  }

  @override
  Stream<Token> get onTokenPut => _onTokenPut.stream;

  @override
  Future<void> deleteToken({bool notificarTokenExcluido = true}) async {
    await localDataSource.deleteAll();
    if (notificarTokenExcluido) {
      _onDeleteToken.add(null);
    }
  }

  @override
  Stream<Null> get onTokenDelete => _onDeleteToken.stream;
}
