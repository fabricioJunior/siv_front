import 'package:core/http/i_http_response.dart';
import 'package:core/http/i_http_source.dart';
import 'package:core/remote_data_sourcers.dart' show IInformacoesParaRequests;
import 'package:flutter_test/flutter_test.dart';
import 'package:produtos/data/remote/referencias_busca_remote_datasource.dart';

class _Resposta implements IHttpResponse {
  @override
  final dynamic body;
  _Resposta(this.body);

  @override
  int get statusCode => 200;
  @override
  String? get message => null;
  @override
  Uri? get uri => null;
}

class _HttpFake implements IHttpSource {
  Uri? ultimaUri;
  dynamic resposta;

  @override
  Future<IHttpResponse> get({required Uri uri}) async {
    ultimaUri = uri;
    return _Resposta(resposta);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _Info extends IInformacoesParaRequests {
  _Info(IHttpSource http)
    : super(
        httpClient: http,
        uriBase: Uri(scheme: 'https', host: 'api.teste'),
      );
}

void main() {
  late _HttpFake http;
  late ReferenciasBuscaRemoteDataSource dataSource;

  setUp(() {
    http = _HttpFake();
    dataSource = ReferenciasBuscaRemoteDataSource(
      informacoesParaRequest: _Info(http),
    );
  });

  test('chama GET /v1/referencias/busca só com os filtros ligados', () async {
    http.resposta = {
      'items': [],
      'meta': {'totalItems': 0, 'totalPages': 0, 'currentPage': 1},
      'resumo': {},
    };

    await dataSource.buscar();

    expect(http.ultimaUri!.path, '/v1/referencias/busca');
    expect(http.ultimaUri!.queryParameters, {
      'orderBy': 'nome',
      'orderDir': 'ASC',
      'page': '1',
    });
  });

  test(
    'manda busca (sem espaços nas pontas), categoria, pendências, ordenação e página',
    () async {
      http.resposta = {
        'items': [],
        'meta': {'totalItems': 0, 'totalPages': 0, 'currentPage': 3},
        'resumo': {},
      };

      await dataSource.buscar(
        busca: '  camisa ',
        categoriaId: 10,
        semNcm: true,
        semPeso: true,
        orderBy: 'atualizadoEm',
        orderDir: 'DESC',
        page: 3,
      );

      expect(http.ultimaUri!.queryParameters, {
        'busca': 'camisa',
        'categoriaId': '10',
        'semNcm': 'true',
        'semPeso': 'true',
        'orderBy': 'atualizadoEm',
        'orderDir': 'DESC',
        'page': '3',
      });
    },
  );

  test('busca só com espaços não é enviada', () async {
    http.resposta = {
      'items': [],
      'meta': {'totalItems': 0, 'totalPages': 0, 'currentPage': 1},
      'resumo': {},
    };

    await dataSource.buscar(busca: '   ');

    expect(http.ultimaUri!.queryParameters.containsKey('busca'), isFalse);
  });

  test('lê itens (com marcaNome), paginação e o resumo dos chips', () async {
    http.resposta = {
      'items': [
        {
          'id': 1,
          'nome': 'Camisa Básica',
          'idExterno': '1001',
          'marcaId': 7,
          'marcaNome': 'Vale',
          'ncm': '61091000',
          'pesoGramas': 250,
          'categoria': {'id': 10, 'nome': 'Camisas', 'inativa': false},
        },
        {'id': 2, 'nome': 'Calça', 'marcaId': null, 'marcaNome': null},
      ],
      'meta': {
        'totalItems': 120,
        'itemCount': 2,
        'itemsPerPage': 50,
        'totalPages': 3,
        'currentPage': 1,
      },
      'resumo': {
        'semNcm': 4,
        'semPeso': 9,
        'categorias': [
          {'id': 10, 'nome': 'Camisas', 'total': 30},
          {'id': 20, 'nome': 'Calças', 'total': 0},
        ],
      },
    };

    final r = await dataSource.buscar();

    expect(r.items.map((i) => i.referencia.nome), ['Camisa Básica', 'Calça']);
    expect(r.items.map((i) => i.marcaNome), ['Vale', null]);
    expect(r.items.first.referencia.categoria?.nome, 'Camisas');
    expect([r.totalItems, r.totalPages, r.currentPage], [120, 3, 1]);
    expect([r.resumo.semNcm, r.resumo.semPeso], [4, 9]);
    expect(r.resumo.categorias.map((c) => (c.id, c.nome, c.total)), [
      (10, 'Camisas', 30),
      (20, 'Calças', 0),
    ]);
  });

  test(
    'resposta sem resumo vira resumo vazio (servidor antigo não derruba a tela)',
    () async {
      http.resposta = {
        'items': [],
        'meta': {'totalItems': 0, 'totalPages': 0, 'currentPage': 1},
      };

      final r = await dataSource.buscar();

      expect(
        [r.resumo.semNcm, r.resumo.semPeso, r.resumo.categorias],
        [0, 0, isEmpty],
      );
    },
  );
}
