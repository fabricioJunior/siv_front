import 'package:autenticacao/models.dart';
import 'package:core/http/i_http_source.dart';
import 'package:core/http/test/informaoces_para_requests_fake.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:siv_front/infra/remote_data_sourcers/usuarios_remote_datasource.dart';

import '../../../packages/autenticacao/test/doubles/fakes.dart';
import '../../../packages/autenticacao/test/doubles/http.mocks.dart';

late UsuariosRemoteDatasource usuariosRemoteDatasource;

var host = 'localhost';
var uriBase = Uri(
  host: host,
);
final IHttpSource client = MockIHttpSource();
void main() {
  setUp(() {
    usuariosRemoteDatasource = UsuariosRemoteDatasource(
      informacoesParaRequest: RequisitosParaRequestFake(
        httpClient: client,
        uriBase: uriBase,
      ),
    );
  });

  group('usuarios remote data source', () {
    test('retorna lista de usuários do servidor', () async {
      var usuario = fakeUsuario(
        criadoEm: DateTime(2025, 02, 17, 17, 21, 40, 739),
        atualizadoEm: DateTime(2025, 02, 17, 17, 21, 40, 739),
        id: 0,
        nome: 'string',
        login: 'string',
        tipo: TipoUsuario.padrao,
      );

      _setupGetUsuarios();

      var result = await usuariosRemoteDatasource.getUsuarios();

      expect(result, [usuario]);
    });
  });
}

void _setupGetUsuarios() {
  var uriToPost = uriBase.replace(
    path: usuariosRemoteDatasource.path,
  );
  var body = RequestTestUtils.jsonFromFile('test/resources/usuarios.json');
  when(client.get(uri: uriToPost)).thenAnswer(
    (_) async => FakeReponse(
      statusCode: 200,
      body: body,
    ),
  );
}
