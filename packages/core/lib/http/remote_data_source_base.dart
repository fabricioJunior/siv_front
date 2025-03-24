import 'package:core/http/i_http_source.dart';
import 'package:core/http/i_http_response.dart';

abstract class RemoteDataSourceBase {
  final IHttpSource httpClient;
  final Uri uriBase;

  String get path;

  RemoteDataSourceBase({
    required IInformacoesParaRequests informacoesParaRequest,
  })  : httpClient = informacoesParaRequest.httpClient,
        uriBase = informacoesParaRequest.uriBase;

  Future<IHttpResponse> get({
    Map<String, String>? queryParameters,
    Map<String, dynamic>? pathParameters,
  }) async {
    var uri = _wrapUri();
    uri = _insertPath(uri, pathParameters);
    var libResponse = await httpClient.get(uri: uri);
    return libResponse;
  }

  Future<IHttpResponse> post({
    required dynamic body,
    Map<String, String>? queryParameters,
    Map<String, dynamic>? pathParameters,
  }) async {
    var uri = _wrapUri();
    uri = _insertPath(uri, pathParameters);
    var libResponse = await httpClient.post(uri: uri, body: body);
    return libResponse;
  }

  Future<IHttpResponse> put({
    required dynamic body,
    Map<String, String>? queryParameters,
    Map<String, dynamic>? pathParameters,
  }) async {
    var uri = _wrapUri();
    uri = _insertPath(uri, pathParameters);
    var libResponse = await httpClient.put(uri: uri, body: body);
    return libResponse;
  }

  Uri _wrapUri({
    Map<String, String>? queryParameters,
  }) {
    return uriBase.replace(
      path: path,
      queryParameters: queryParameters,
    );
  }

  Uri _insertPath(Uri uri, Map<String, dynamic>? pathParameters) {
    String result = path;
    if (pathParameters != null) {
      for (var key in pathParameters.keys) {
        result = result.replaceAll('{$key}', _formatData(pathParameters[key]));
      }
    }
    if (result.contains('{')) {
      result = result.replaceAll(RegExp('\\{.*?\\}'), '');
    }

    return uri.replace(
      path: result,
    );
  }

  String _formatData(dynamic data) {
    if (data is DateTime) {
      return data.toIso8601String();
    }
    if (data == null) {
      return '';
    }
    return data.toString();
  }
}

abstract class IInformacoesParaRequests {
  final IHttpSource httpClient;
  final Uri uriBase;

  IInformacoesParaRequests({required this.httpClient, required this.uriBase});
}
