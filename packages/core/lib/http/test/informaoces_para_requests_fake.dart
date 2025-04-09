import 'dart:convert';
import 'dart:io';

import 'package:core/remote_data_sourcers.dart';
import 'package:flutter/foundation.dart';

@visibleForTesting
class RequisitosParaRequestFake implements IInformacoesParaRequests {
  @override
  final IHttpSource httpClient;

  @override
  final Uri uriBase;

  RequisitosParaRequestFake({required this.httpClient, required this.uriBase});
}

class RequestTestUtils {
  static dynamic jsonFromFile(String pathFile) {
    var dir = Directory.current;
    while (
        dir.listSync().any((entity) => entity.path.endsWith('pubspec.yaml'))) {
      dir = dir.parent;
    }
    var file = File('${dir.path}/$pathFile');
    var jsonString = file.readAsStringSync();
    return jsonDecode(jsonString);
  }
}

class FakeReponse implements IHttpResponse {
  @override
  final Object? body;

  @override
  final String? message;

  @override
  final int statusCode;

  @override
  final Uri? uri;

  FakeReponse({this.body, this.message, required this.statusCode, this.uri});
}
