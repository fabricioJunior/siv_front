import 'dart:convert';
import 'dart:developer';

import 'package:core/http/http_implementacao/http_response.dart';
import 'package:core/http/i_http_response.dart';
import 'package:http/http.dart' as lib;

import '../i_http_source.dart';

final Map<String, String> _defaultHeaders = {
  'Content-Type': 'application/json'
};

class HttpSource implements IHttpSource {
  final lib.Client client;

  HttpSource({required this.client});

  @override
  Future<IHttpResponse> delete({required Uri uri}) async {
    var response = await client.delete(uri);

    return HttpResponse(response: response);
  }

  @override
  Future<IHttpResponse> get({
    required Uri uri,
  }) async {
    var response = await client.get(uri);

    return HttpResponse(response: response);
  }

  @override
  Future<IHttpResponse> post({
    required dynamic body,
    required Uri uri,
  }) async {
    log(jsonEncode(body));
    var response = await client.post(uri, body: body, headers: _defaultHeaders);

    return HttpResponse(response: response);
  }

  @override
  Future<IHttpResponse> put({required body, required Uri uri}) async {
    log(jsonEncode(body));
    var response =
        await client.put(uri, body: jsonEncode(body), headers: _defaultHeaders);

    return HttpResponse(response: response);
  }
}
