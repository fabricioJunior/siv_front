import 'package:core/http/test/informaoces_para_requests_fake.dart';
import 'package:empresas/data/remote_data_sourcers/empresas_remote_data_source.dart';
import 'package:empresas/domain/entities/empresa.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../doubles/fakes.dart';
import '../../doubles/http.mocks.dart';

var httpSource = MockIHttpSource();
var host = 'localhost';
var uriBase = Uri(
  host: host,
);
late EmpresasRemoteDataSource empresasRemoteDataSource;

void main() {
  setUp(() {
    empresasRemoteDataSource = EmpresasRemoteDataSource(
      informacoesParaRequest: MockInformacoesParaRequests(
        httpClient: httpSource,
        uriBase: uriBase,
      ),
    );
  });

  test('retorna nova empresa criada no servidor', () async {
    var empresa = fakeEmpresa();
    _setupPostEmpresa(empresa);

    var response = await empresasRemoteDataSource.postEmpresa(empresa);

    expect(response, empresa.toDto());
  });
}

void _setupPostEmpresa(Empresa empresa) {
  var body = RequestTestUtils.jsonFromFile(
    'empresas/test/resources/empresa.json',
  );
  var uri = empresasRemoteDataSource.getPath();

  when(
    httpSource.post(
      body: empresasRemoteDataSource.toJson(
        empresa.toDto().toJson(),
      ),
      uri: uri,
    ),
  ).thenAnswer(
    (_) async => FakeHttpResponse(statusCode: 200, body: body),
  );
}
