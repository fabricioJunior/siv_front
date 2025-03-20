import 'package:core/http/i_http_response.dart';

abstract class IHttpSource {
  Future<IHttpResponse> post({
    required dynamic body,
    required Uri uri,
  });

  Future<IHttpResponse> get({
    required Uri uri,
  });

  Future<IHttpResponse> delete({
    required Uri uri,
  });
}
