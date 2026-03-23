import 'dart:io';

import 'package:core/http/i_http_response.dart';
import 'package:http/http.dart';

abstract class IHttpSource {
  Future<IHttpResponse> post({
    required dynamic body,
    required Uri uri,
  });
  Future<IHttpResponse> put({
    required dynamic body,
    required Uri uri,
  });

  Future<IHttpResponse> get({
    required Uri uri,
  });

  Future<IHttpResponse> delete({
    required Uri uri,
  });

  Future<IHttpResponse> postMultipart({
    required Uri uri,
    required String field,
    required File file,
    Map<String, dynamic>? body,
    bool compressImage = true,
  });
}
