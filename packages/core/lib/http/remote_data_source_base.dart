import 'dart:convert';
import 'dart:developer';

import 'package:core/http/i_http_source.dart';
import 'package:core/http/i_http_response.dart';
import 'package:flutter/foundation.dart';

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
    _validateResponse(libResponse);
    return libResponse;
  }

  Future<IHttpResponse> post({
    required dynamic body,
    Map<String, String>? queryParameters,
    Map<String, dynamic>? pathParameters,
  }) async {
    var uri = _wrapUri();
    uri = _insertPath(uri, pathParameters);
    var libResponse = await httpClient.post(uri: uri, body: jsonEncode(body));
    _validateResponse(libResponse);
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
    _validateResponse(libResponse);
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

  @visibleForTesting
  Uri getPath({
    Map<String, dynamic>? pathParameters,
  }) {
    var uri = _wrapUri();
    uri = _insertPath(uri, pathParameters);
    return uri;
  }

  @visibleForTesting
  String toJson(Map<String, dynamic> json) {
    return jsonEncode(json);
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

  void _validateResponse(IHttpResponse response) {
    if (response.statusCode != 200 &&
        response.statusCode != 204 &&
        response.statusCode != 201) {
      String errorMessage;

      switch (response.statusCode) {
        case 400:
          errorMessage =
              'Requisição inválida (Bad Request). Verifique os dados enviados.';
          break;
        case 401:
          errorMessage =
              'Não autorizado (Unauthorized). Verifique suas credenciais.';
          break;
        case 403:
          errorMessage =
              'Proibido (Forbidden). Você não tem permissão para acessar este recurso.';
          break;
        case 404:
          errorMessage =
              'Recurso não encontrado (Not Found). Verifique o endpoint ou o recurso solicitado.';
          break;
        case 500:
          errorMessage =
              'Erro interno do servidor (Internal Server Error). Tente novamente mais tarde.';
          break;
        case 503:
          errorMessage =
              'Serviço indisponível (Service Unavailable). O servidor está temporariamente fora do ar.';
          break;
        default:
          errorMessage =
              'Erro inesperado: Código ${response.statusCode}. Mensagem: ${response.body}';
      }
      log(response.body.toString());
      throw HttpException(
        errorMessage,
        statusCode: response.statusCode,
      );
    }
  }
}

class HttpException implements Exception {
  final String message;
  final int statusCode;

  HttpException(this.message, {required this.statusCode});

  @override
  String toString() => 'HttpException: $message (Status code: $statusCode)';
}

abstract class IRemoteDto {
  Map<String, dynamic> toJson();
}

abstract class IInformacoesParaRequests {
  final IHttpSource httpClient;
  final Uri uriBase;

  IInformacoesParaRequests({required this.httpClient, required this.uriBase});
}
