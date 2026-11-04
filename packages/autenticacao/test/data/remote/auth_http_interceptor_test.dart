import 'dart:async';

import 'package:autenticacao/data/remote/auth_http_interceptor.dart';
import 'package:autenticacao/domain/data/repositories/i_token_repository.dart';
import 'package:autenticacao/domain/models/resultado_renovacao_token.dart';
import 'package:autenticacao/domain/models/token.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class FakeTokenRepository implements ITokenRepository {
  Token? token = _tk('velho');
  ResultadoRenovacaoToken resultado = TokenRenovado(_tk('novo'));
  int renovacoes = 0;
  int deletes = 0;
  Completer<void>? segurar;
  Future<ResultadoRenovacaoToken>? _emAndamento;

  @override
  Future<Token?> recuperarToken() async => token;

  @override
  Future<ResultadoRenovacaoToken> renovarToken() {
    return _emAndamento ??= () async {
      renovacoes++;
      await segurar?.future;
      final r = resultado;
      if (r is TokenRenovado) token = r.token;
      _emAndamento = null;
      return r;
    }();
  }

  @override
  Future<void> deleteToken({bool notificarTokenExcluido = true}) async {
    deletes++;
    token = null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Token _tk(String jwt) => Token(
      jwtToken: jwt,
      dataDeCriacao: DateTime(2024),
      dataDeExpiracao: DateTime(2024),
      refreshToken: 'r',
    );

http.Request _req() => http.Request('GET', Uri.parse('https://x/v1/foo'))
  ..headers['Authorization'] = 'Bearer velho';

http.Response _resp401(http.BaseRequest r) =>
    http.Response('', 401, request: r);

void main() {
  late FakeTokenRepository repo;
  late AuthHttpInterceptor interceptor;
  late List<String> enviados;
  late MockClient client;

  setUp(() {
    repo = FakeTokenRepository();
    interceptor = AuthHttpInterceptor(repo);
    enviados = [];
    client = MockClient((r) async {
      enviados.add(r.headers['Authorization']!);
      return http.Response('ok', 200);
    });
  });

  Future<http.BaseResponse> intercepta(http.BaseResponse r) => http.runWithClient(
        () async => await interceptor.interceptResponse(response: r),
        () => client,
      );

  test('(i) 401 em Request normal renova, reenvia e mantem token', () async {
    final r = await intercepta(_resp401(_req()));
    expect(r.statusCode, 200);
    expect(enviados, ['Bearer novo']);
    expect(repo.deletes, 0);
    expect(repo.token!.jwtToken, 'novo');
  });

  test('(ii) 401 em multipart com renovacao OK nao apaga token', () async {
    final multipart = http.MultipartRequest('POST', Uri.parse('https://x/up'))
      ..headers['Authorization'] = 'Bearer velho';
    final r = await intercepta(
      http.StreamedResponse(const Stream.empty(), 401, request: multipart),
    );
    expect(r.statusCode, 401);
    expect(repo.deletes, 0);
    expect(repo.token!.jwtToken, 'novo');
    expect(enviados, isEmpty);
  });

  test('(iii) refresh rejeitado apaga token', () async {
    repo.resultado = const RenovacaoRejeitada();
    final r = await intercepta(_resp401(_req()));
    expect(r.statusCode, 401);
    expect(repo.deletes, 1);
  });

  test('(iv) falha transitoria mantem token', () async {
    repo.resultado = const RenovacaoIndisponivel();
    final r = await intercepta(_resp401(_req()));
    expect(r.statusCode, 401);
    expect(repo.deletes, 0);
    expect(repo.token!.jwtToken, 'velho');
  });

  test('(v) dois 401 simultaneos geram um unico refresh', () async {
    repo.segurar = Completer();
    final f = Future.wait([
      intercepta(_resp401(_req())),
      intercepta(_resp401(_req())),
    ]);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    repo.segurar!.complete();
    final rs = await f;
    expect(rs.map((r) => r.statusCode), [200, 200]);
    expect(repo.renovacoes, 1);
    expect(enviados, ['Bearer novo', 'Bearer novo']);
  });

  test('(vi) interceptRequest sem token nao lanca', () async {
    repo.token = null;
    final req = http.Request('GET', Uri.parse('https://x/v1/foo'));
    final out = await interceptor.interceptRequest(request: req);
    expect(out.headers.containsKey('Authorization'), isFalse);
  });
}
