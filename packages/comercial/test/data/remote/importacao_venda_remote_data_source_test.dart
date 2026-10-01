import 'dart:io';
import 'dart:typed_data';

import 'package:comercial/data/remote/importacao_venda_remote_data_source.dart';
import 'package:core/http/i_http_response.dart';
import 'package:core/http/i_http_source.dart';
import 'package:core/remote_data_sourcers.dart' show IInformacoesParaRequests;
import 'package:flutter_test/flutter_test.dart';

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

// Registra as chamadas HTTP; só implementa o que o data source usa.
class _HttpFake implements IHttpSource {
  final chamadas = <String>[];
  Map<String, dynamic>? ultimoBody;

  @override
  Future<Uint8List> getBytes({required Uri uri}) async {
    chamadas.add('GET(bytes) ${uri.path}');
    return Uint8List.fromList([1, 2, 3]);
  }

  @override
  Future<IHttpResponse> get({required Uri uri}) async {
    chamadas.add('GET ${uri.path}');
    return _Resposta({'id': 7, 'situacao': 'concluida'});
  }

  @override
  Future<IHttpResponse> postMultipart({
    required Uri uri,
    required String field,
    required Uint8List bytes,
    required String fileName,
    required FileType fileType,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool compressImage = true,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    chamadas.add('POST(multipart) ${uri.path}');
    ultimoBody = body;
    return _Resposta({'id': 7, 'situacao': 'pendente'});
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _Info extends IInformacoesParaRequests {
  _Info(IHttpSource http) : super(httpClient: http, uriBase: Uri(scheme: 'https', host: 'api.teste'));
}

void main() {
  late _HttpFake http;
  late ImportacaoVendaRemoteDataSource dataSource;

  setUp(() {
    http = _HttpFake();
    dataSource = ImportacaoVendaRemoteDataSource(informacoesParaRequest: _Info(http));
  });

  test('modelo e upload usam /v1/importacao/vendas', () async {
    final arquivo = File('${Directory.systemTemp.path}/vendas_teste.csv')..writeAsStringSync('x');

    await dataSource.baixarTemplateCsv();
    final importacao = await dataSource.importarCsv(
      filePath: arquivo.path,
      tabelaDePrecoId: 4,
      funcionarioId: 9,
    );

    expect(http.chamadas, ['GET(bytes) /v1/importacao/vendas/template', 'POST(multipart) /v1/importacao/vendas']);
    expect(http.ultimoBody, {'tabelaDePrecoId': '4', 'funcionarioId': '9'});
    expect(importacao.id, 7);
  });

  test('status usa GET /v1/importacao/:id (singular, o que o backend expõe), não /v1/importacoes/:id', () async {
    final importacao = await dataSource.consultarImportacao(7);

    expect(http.chamadas, ['GET /v1/importacao/7']);
    expect(importacao.situacao.finalizada, isTrue);
  });

  test('depois de consultar o status, o upload volta para a rota de vendas', () async {
    final arquivo = File('${Directory.systemTemp.path}/vendas_teste.csv')..writeAsStringSync('x');

    await dataSource.consultarImportacao(7);
    await dataSource.importarCsv(filePath: arquivo.path, tabelaDePrecoId: 1, funcionarioId: 1);

    expect(http.chamadas, ['GET /v1/importacao/7', 'POST(multipart) /v1/importacao/vendas']);
  });
}
