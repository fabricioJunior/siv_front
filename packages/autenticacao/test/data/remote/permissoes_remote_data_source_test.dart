import 'package:autenticacao/data/remote/permissoes_remote_data_source.dart';
import 'package:autenticacao/data/remote/dtos/permissao_dto.dart';
import 'package:autenticacao/domain/models/permissao.dart';
import 'package:core/http/i_http_source.dart';
import 'package:core/http/test/informaoces_para_requests_fake.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../doubles/fakes.dart';
import '../../doubles/http.mocks.dart';

var host = 'localhost';
var uriBase = Uri(
  host: host,
);
late PermissoesRemoteDataSource dataSource;
final IHttpSource client = MockIHttpSource();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    dataSource = PermissoesRemoteDataSource(
      informacoesParaRequest: MockInformacoesParaRequests(
        httpClient: client,
        uriBase: uriBase,
      ),
    );
  });

  group('PermissoesRemoteDataSource', () {
    test('deve retornar uma lista de permissões ao chamar getPermissoes',
        () async {
      // Mock da resposta do servidor
      await _setupMockGetWithPermissoesJson();
      var permissoes = _permissoesFake();
      // Chamada do método
      final result = await dataSource.getPermissoes();

      // Verificações
      expect(result, permissoes.map((e) => e.toPermissaoDto()));
      expect(result.length, 4);
    });
  });
}

Future<void> _setupMockGetWithPermissoesJson() async {
  var uri = uriBase.replace(
    path: dataSource.path,
  );

  when(client.get(uri: uri)).thenAnswer((_) async {
    return FakeHttpResponse(
      statusCode: 200,
      body: RequestTestUtils.jsonFromFile(
          'autenticacao/test/resources/permissoes.json'),
    );
  });
}

List<Permissao> _permissoesFake() {
  return [
    fakePermissao(
      id: 1.toString(),
      nome: "Componente A",
      descontinuado: false,
    ),
    fakePermissao(
      id: 2.toString(),
      nome: "Componente B",
      descontinuado: true,
    ),
    fakePermissao(
      id: 3.toString(),
      nome: "Componente C",
      descontinuado: false,
    ),
    fakePermissao(
      id: 4.toString(),
      nome: "Componente D",
      descontinuado: true,
    ),
  ];
}
