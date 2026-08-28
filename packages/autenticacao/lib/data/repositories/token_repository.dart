import 'dart:async';
import 'dart:developer';

import 'package:autenticacao/domain/data/data_sourcers/local/i_token_local_data_source.dart';
import 'package:autenticacao/domain/data/data_sourcers/remote/i_token_remote_data_source.dart';
import 'package:autenticacao/domain/data/repositories/i_token_repository.dart';
import 'package:autenticacao/domain/models/token.dart';

class TokenRepository implements ITokenRepository {
  final ITokenLocalDataSource<Token> localDataSource;
  final ITokenRemoteDataSource remoteDataSource;

  final StreamController<Token> _onTokenPut = StreamController.broadcast();

  final StreamController<Null> _onDeleteToken = StreamController.broadcast();

  TokenRepository({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<void> putToken(Token token) async {
    await localDataSource.put(token);
    _onTokenPut.add(token);
  }

  @override
  Future<Token?> recuperarToken() async {
    var tokens = await localDataSource.fetchAll();

    return tokens.isEmpty ? null : tokens.first;
  }

  @override
  Future<Token?> renovarToken() async {
    var tokenAtual = await recuperarToken();
    if (tokenAtual?.refreshToken == null) {
      return null;
    }

    var tokenNovo = await remoteDataSource.renovarToken(
      refreshToken: tokenAtual!.refreshToken!,
      idEmpresa: tokenAtual.idEmpresa,
    );
    if (tokenNovo == null) {
      return null;
    }

    // dataBaseId da box e' hash do jwtToken (muda a cada renovacao) -- sem apagar antes, cada
    // refresh acumularia uma entrada nova na box em vez de substituir (mesmo cuidado do login,
    // ver CriarTokenDeAutenticacao).
    await deleteToken(notificarTokenExcluido: false);
    await putToken(tokenNovo);
    return tokenNovo;
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
    // ignore: void_checks
    log('chegou aqui');
    if (notificarTokenExcluido) {
      _onDeleteToken.add(null);
    }
  }

  @override
  Stream<Null> get onTokenDelete => _onDeleteToken.stream;
}
