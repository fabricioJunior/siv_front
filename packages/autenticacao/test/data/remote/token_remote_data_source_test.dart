import 'dart:convert';

import 'package:autenticacao/data/remote_data_sourcers.dart';
import 'package:autenticacao/domain/models/token.dart';
import 'package:core/http/i_http_source.dart';
import 'package:core/http/test/informaoces_para_requests_fake.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../doubles/http.mocks.dart';

late TokenRemoteDatasource remoteDatasource;

var host = 'localhost';
var uriBase = Uri(
  host: host,
);
final IHttpSource client = MockIHttpSource();

void main() {
  setUp(() {
    remoteDatasource = TokenRemoteDatasource(
        informacoesParaRequest: MockInformacoesParaRequests(
      uriBase: uriBase,
      httpClient: client,
    ));
  });

  test('retorna token após realizar autenticação com o servidor', () async {
    _setupCreateToken('usuario', 'senha');
    var result = await remoteDatasource.getToken(
      usuario: 'usuario',
      senha: 'senha',
      empresaId: null,
    );
    expect(
      result,
      Token(
        jwtToken: 'token',
        dataDeCriacao: DateTime.now(),
        dataDeExpiracao: DateTime.now(),
      ),
    );
  });
}

void _setupCreateToken(
  String usuario,
  String senha,
) {
  var uriToPost = uriBase.replace(
    path: remoteDatasource.path,
  );
  when(
    client.post(
      uri: uriToPost,
      body: jsonEncode({"usuario": usuario, "senha": senha}),
    ),
  ).thenAnswer(
      (_) async => FakeHttpResponse(statusCode: 200, body: {'token': 'token'}));
}
