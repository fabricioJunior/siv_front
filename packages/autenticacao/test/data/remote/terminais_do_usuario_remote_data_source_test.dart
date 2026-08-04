import 'package:autenticacao/data/remote_data_sourcers.dart';
import 'package:core/http/i_http_source.dart';
import 'package:core/http/test/informaoces_para_requests_fake.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../doubles/http.mocks.dart';

late TerminaisDoUsuarioRemoteDataSource remoteDatasource;

var host = 'localhost';
var uriBase = Uri(host: host);
final IHttpSource client = MockIHttpSource();

void main() {
  setUp(() {
    remoteDatasource = TerminaisDoUsuarioRemoteDataSource(
      informacoesParaRequest: MockInformacoesParaRequests(
        uriBase: uriBase,
        httpClient: client,
      ),
    );
  });

  test('busca terminais escopados pela empresa informada no path', () async {
    final uriEsperada = uriBase.replace(
      path: '/v1/usuarios/5/terminais/empresas/9',
    );
    when(client.get(uri: uriEsperada)).thenAnswer(
      (_) async => FakeHttpResponse(statusCode: 200, body: []),
    );

    final result = await remoteDatasource.buscarTerminaisDoUsuario(5, 9);

    expect(result, isEmpty);
    verify(client.get(uri: uriEsperada)).called(1);
  });
}
