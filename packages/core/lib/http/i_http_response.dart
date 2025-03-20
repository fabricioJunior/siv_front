abstract class IHttpResponse {
  dynamic get body;

  int get statusCode;

  String? get message;

  Uri? get uri;
}
