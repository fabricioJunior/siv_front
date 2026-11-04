import 'package:autenticacao/data/repositories/token_repository.dart';
import 'package:autenticacao/domain/data/data_sourcers/local/i_token_local_data_source.dart';
import 'package:autenticacao/domain/data/data_sourcers/remote/i_token_remote_data_source.dart';
import 'package:autenticacao/domain/models/resultado_renovacao_token.dart';
import 'package:autenticacao/domain/models/token.dart';
import 'package:flutter_test/flutter_test.dart';

Token _tk(String jwt) => Token(
      jwtToken: jwt,
      dataDeCriacao: DateTime(2024),
      dataDeExpiracao: DateTime(2024),
      refreshToken: 'r',
    );

class _Local implements ITokenLocalDataSource<Token> {
  final dados = <Token>[_tk('velho')];
  int deletes = 0;
  @override
  Future<Iterable<Token>> fetchAll() async => List.of(dados);
  @override
  Future<void> put(Token t) async => dados.add(t);
  @override
  Future<void> deleteAll() async {
    deletes++;
    dados.clear();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _Remote implements ITokenRemoteDataSource {
  ResultadoRenovacaoToken resultado = TokenRenovado(_tk('novo'));
  int chamadas = 0;
  @override
  Future<ResultadoRenovacaoToken> renovarToken({
    required String refreshToken,
    required int? idEmpresa,
  }) async {
    chamadas++;
    await Future<void>.delayed(const Duration(milliseconds: 20));
    return resultado;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late _Local local;
  late _Remote remote;
  late TokenRepository repo;

  setUp(() {
    local = _Local();
    remote = _Remote();
    repo = TokenRepository(localDataSource: local, remoteDataSource: remote);
  });

  test('chamadas concorrentes dividem um unico refresh', () async {
    final rs = await Future.wait([repo.renovarToken(), repo.renovarToken()]);
    expect(rs.every((r) => r is TokenRenovado), isTrue);
    expect(remote.chamadas, 1);
    expect((await repo.recuperarToken())!.jwtToken, 'novo');
  });

  test('token nunca fica nulo durante a troca', () async {
    final f = repo.renovarToken();
    final leituras = <Token?>[];
    for (var i = 0; i < 5; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 6));
      leituras.add(await repo.recuperarToken());
    }
    await f;
    expect(leituras.every((t) => t != null), isTrue);
  });

  test('falha transitoria nao mexe no armazenamento', () async {
    remote.resultado = const RenovacaoIndisponivel();
    expect(await repo.renovarToken(), isA<RenovacaoIndisponivel>());
    expect(local.deletes, 0);
    expect((await repo.recuperarToken())!.jwtToken, 'velho');
  });
}
