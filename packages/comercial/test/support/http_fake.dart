import 'dart:convert';
import 'dart:typed_data';

import 'package:core/http/i_http_response.dart';
import 'package:core/http/i_http_source.dart';
import 'package:core/remote_data_sourcers.dart' show IInformacoesParaRequests;

class RespostaFake implements IHttpResponse {
  @override
  final dynamic body;
  RespostaFake(this.body);

  @override
  int get statusCode => 200;
  @override
  String? get message => null;
  @override
  Uri? get uri => null;
}

/// Registra "METHOD path?query" e o corpo enviado; responde sempre [resposta].
class HttpFake implements IHttpSource {
  dynamic resposta;
  final chamadas = <String>[];
  final bodies = <dynamic>[];

  HttpFake([this.resposta = const <String, dynamic>{}]);

  String _rotulo(String m, Uri uri) =>
      '$m ${uri.path}${uri.hasQuery ? '?${uri.query}' : ''}';

  Future<IHttpResponse> _reg(String m, Uri uri, [dynamic body]) async {
    chamadas.add(_rotulo(m, uri));
    bodies.add(body is String ? jsonDecode(body) : body);
    return RespostaFake(resposta);
  }

  @override
  Future<IHttpResponse> get({required Uri uri}) => _reg('GET', uri);
  @override
  Future<IHttpResponse> post({required dynamic body, required Uri uri}) =>
      _reg('POST', uri, body);
  @override
  Future<IHttpResponse> put({required dynamic body, required Uri uri}) =>
      _reg('PUT', uri, body);
  @override
  Future<IHttpResponse> patch({required dynamic body, required Uri uri}) =>
      _reg('PATCH', uri, body);
  @override
  Future<IHttpResponse> delete({required Uri uri, dynamic body}) =>
      _reg('DELETE', uri, body);
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
  }) =>
      _reg('POST(multipart)', uri, {'field': field, 'fileName': fileName});

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class InfoFake extends IInformacoesParaRequests {
  InfoFake(IHttpSource http)
      : super(httpClient: http, uriBase: Uri(scheme: 'https', host: 'api.teste'));
}
