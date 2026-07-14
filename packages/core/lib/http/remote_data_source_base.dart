import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:core/http/i_http_source.dart';
import 'package:core/http/i_http_response.dart';
import 'package:flutter/foundation.dart';

abstract class RemoteDataSourceBase {
  final IHttpSource httpClient;
  final IInformacoesParaRequests informacoesParaRequest;

  Uri get uriBase => informacoesParaRequest.uriBase;

  String get path;

  RemoteDataSourceBase({
    required this.informacoesParaRequest,
  }) : httpClient = informacoesParaRequest.httpClient;

  Future<IHttpResponse> get({
    Map<String, String>? queryParameters,
    Map<String, dynamic>? pathParameters,
  }) async {
    var uri = _wrapUri(
      queryParameters: queryParameters,
    );
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
    var uri = _wrapUri(queryParameters: queryParameters);
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
    var uri = _wrapUri(
      queryParameters: queryParameters,
    );
    uri = _insertPath(uri, pathParameters);
    var libResponse = await httpClient.put(uri: uri, body: body);
    _validateResponse(libResponse);
    return libResponse;
  }

  Future<IHttpResponse> postFile({
    String field = 'file',
    required File file,
    Map<String, String>? queryParameters,
    Map<String, dynamic>? pathParameters,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    FileType fileType = FileType.other,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    var uri = _wrapUri(
      queryParameters: queryParameters,
    );
    uri = _insertPath(uri, pathParameters);
    var libResponse = await httpClient.postMultipart(
      uri: uri,
      field: field,
      file: file,
      body: body,
      headers: headers,
      fileType: fileType,
      onSendProgress: onSendProgress,
    );
    _validateResponse(libResponse);
    return libResponse;
  }

  Future<IHttpResponse> patch({
    required dynamic body,
    Map<String, String>? queryParameters,
    Map<String, dynamic>? pathParameters,
  }) async {
    var uri = _wrapUri(queryParameters: queryParameters);
    uri = _insertPath(uri, pathParameters);
    var libResponse = await httpClient.patch(uri: uri, body: body);
    _validateResponse(libResponse);
    return libResponse;
  }

  Future<IHttpResponse> delete({
    Map<String, String>? queryParameters,
    Map<String, dynamic>? pathParameters,
    dynamic body,
  }) async {
    var uri = _wrapUri(
      queryParameters: queryParameters,
    );
    uri = _insertPath(uri, pathParameters);
    var libResponse = await httpClient.delete(
      uri: uri,
      body: body == null ? null : jsonEncode(body),
    );
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
          errorMessage = 'Requisição inválida (Bad Request).';
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
          errorMessage = 'Erro inesperado: Código ${response.statusCode}.';
      }

      final apiMessage = _extractApiMessage(response);
      if (apiMessage != null && apiMessage.isNotEmpty) {
        errorMessage = '$errorMessage $apiMessage';
      }

      log(response.body.toString());
      throw HttpException(
        errorMessage,
        statusCode: response.statusCode,
        apiMessage: apiMessage,
      );
    }
  }

  /// Extrai a mensagem retornada pela API no corpo da resposta de erro,
  /// procurando pelos campos comuns (`message`, `error`, `errors`).
  /// Retorna `null` se o corpo não existir ou não puder ser interpretado.
  String? _extractApiMessage(IHttpResponse response) {
    dynamic body;
    try {
      body = response.body;
    } catch (_) {
      final raw = response.message;
      return (raw != null && raw.trim().isNotEmpty) ? raw.trim() : null;
    }

    if (body == null) return null;

    if (body is Map) {
      final dynamic raw = body['message'] ?? body['error'] ?? body['errors'];
      if (raw == null) return null;
      if (raw is List) {
        // Erros de validação de DTO (class-validator) chegam como
        // [{ campo: ["mensagem"] }] em vez de string simples -- sem isso,
        // Map.toString() produz algo ilegível tipo "{documento: [Documento
        // já vinculado a outra pessoa]}" na tela.
        return raw
            .map((e) {
              if (e is Map) {
                return e.values
                    .expand((v) => v is List ? v : [v])
                    .map((v) => v.toString())
                    .join(' ');
              }
              return e.toString();
            })
            .join(' ')
            .trim();
      }
      final text = raw.toString().trim();
      return text.isEmpty ? null : text;
    }

    if (body is String) {
      final text = body.trim();
      return text.isEmpty ? null : text;
    }

    return null;
  }
}

class HttpException implements Exception {
  final String message;
  final int statusCode;

  /// Mensagem original retornada pela API no corpo da resposta (quando
  /// disponível), sem o prefixo genérico do status HTTP. Útil para exibir
  /// ao usuário o motivo real do erro reportado pelo backend.
  final String? apiMessage;

  HttpException(this.message, {required this.statusCode, this.apiMessage});

  @override
  String toString() => 'HttpException: $message (Status code: $statusCode)';
}

/// Retorna a mensagem vinda da API (`HttpException.apiMessage`) quando
/// disponível, ou [fallback] caso contrário. Útil nos blocs para exibir ao
/// usuário o motivo real do erro reportado pelo backend, sem perder a
/// mensagem fixa de fallback já existente em cada fluxo.
String mensagemDeErroApi(Object error, String fallback) {
  if (error is HttpException) {
    final apiMessage = error.apiMessage;
    if (apiMessage != null && apiMessage.trim().isNotEmpty) {
      return apiMessage;
    }
  }
  return fallback;
}

abstract class IRemoteDto {
  Map<String, dynamic> toJson();
}

abstract class IInformacoesParaRequests {
  final IHttpSource httpClient;
  final Uri uriBase;

  IInformacoesParaRequests({required this.httpClient, required this.uriBase});
}
