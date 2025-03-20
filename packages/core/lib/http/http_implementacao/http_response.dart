import 'dart:convert';

import 'package:core/http/i_http_response.dart';
import 'package:http/http.dart' as lib;

class HttpResponse implements IHttpResponse {
  final lib.Response response;

  HttpResponse({required this.response});

  @override
  String? get message => response.body;

  @override
  dynamic get body => jsonDecode(response.body);

  @override
  int get statusCode => response.statusCode;

  @override
  Uri? get uri => response.request?.url;
}
