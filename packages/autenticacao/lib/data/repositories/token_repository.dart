import 'dart:async';

import 'package:autenticacao/data/local/dtos/token_dto.dart' as local;
import 'package:autenticacao/domain/data/data_sourcers/local/i_token_local_data_source.dart';
import 'package:autenticacao/domain/data/data_sourcers/remote/i_token_remote_data_source.dart';
import 'package:autenticacao/domain/data/repositories/i_token_repository.dart';
import 'package:autenticacao/domain/models/token.dart';

class TokenRepository implements ITokenRepository {
  final ITokenLocalDataSource localDataSource;
  final ITokenRemoteDataSource remoteDataSource;

  final StreamController<Token> _onTokenPut = StreamController.broadcast();

  final StreamController<Null> _onDeleteToken = StreamController.broadcast();

  TokenRepository({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<void> putToken(Token token) async {
    await localDataSource.put(token.toLocalDto());
    _onTokenPut.add(token);
  }

  @override
  Future<Token?> recuperarToken() async {
    var tokens = await localDataSource.fetchAll();

    return tokens.isEmpty ? null : tokens.first;
  }

  @override
  Future<Token?> recuperarTokenDoServidor(
    String usuario,
    String senha,
  ) {
    return remoteDataSource.getToken(
      usuario: usuario,
      senha: senha,
      empresaId: null,
    );
  }

  @override
  Stream<Token> get onTokenPut => _onTokenPut.stream;

  @override
  Future<void> deleteToken() async {
    await localDataSource.deleteAll();
    // ignore: void_checks
    _onDeleteToken.add(null);
  }

  @override
  Stream<Null> get onTokenDelete => _onDeleteToken.stream;
}

extension EntityToDto on Token {
  local.TokenDto toLocalDto() => local.TokenDto(
        jwtToken: jwtToken,
        dataDeCriacao: dataDeCriacao,
        dataDeExpiracao: dataDeExpiracao,
      );
}
