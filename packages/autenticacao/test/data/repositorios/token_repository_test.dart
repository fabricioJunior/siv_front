import 'package:autenticacao/data/repositories/token_repository.dart';
import 'package:autenticacao/domain/models/token.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../doubles/fakes.dart';
import '../../doubles/local_data_source.mocks.dart';
import '../../doubles/remote_data_source.mocks.dart';

final tokenLocalDataSource = MockITokenLocalDataSource();
final tokenRemoteDataSource = MockITokenRemoteDataSource();

late TokenRepository tokenRepository;
void main() {
  setUp(() {
    tokenRepository = TokenRepository(
      localDataSource: tokenLocalDataSource,
      remoteDataSource: tokenRemoteDataSource,
    );
  });
  int idEmpresa = 123;
  group('token repository', () {
    test('putToken salva token localmente', () async {
      var token = fakeToken();

      await tokenRepository.putToken(token);

      verify(tokenLocalDataSource.put(token.toLocalDto()));
    });

    test('recuperarToken retorna token armazenado localmente', () async {
      var token = fakeToken();
      _setupFetchToken(token);
      var resultado = await tokenRepository.recuperarToken();

      expect(resultado!.toLocalDto(), token.toLocalDto());
    });
    test('recuperarToken retorna null quando não token armazenado', () async {
      _setupFetchToken(null);
      var resultado = await tokenRepository.recuperarToken();

      expect(resultado, null);
    });

    test(
      'recuperarTokenDoServidor recupera token junto ao servidor',
      () async {
        var usuario = 'user';
        var senha = 'senha123';
        var token = fakeToken();
        _setupGetToken(usuario, senha, idEmpresa, token: token);

        var result = await tokenRepository.recuperarTokenDoServidor(
          usuario,
          senha,
          idEmpresa,
        );

        expect(result, token);
      },
    );
  });
}

void _setupGetToken(
  String usuario,
  String senha,
  int? idEmpresa, {
  required Token token,
}) {
  when(
    tokenRemoteDataSource.getToken(
      usuario: usuario,
      senha: senha,
      empresaId: idEmpresa,
    ),
  ).thenAnswer((_) async => token);
}

void _setupFetchToken(Token? token) {
  when(tokenLocalDataSource.fetchAll()).thenAnswer(
    (_) async => token == null
        ? []
        : [
            token.toLocalDto(),
          ],
  );
}
