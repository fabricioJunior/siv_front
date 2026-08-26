import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:core/http/http_implementacao/http_response.dart';
import 'package:image/image.dart' as img;
import 'package:core/http/i_http_response.dart';
import 'package:core/http/remote_data_source_base.dart' show HttpException;
import 'package:http/http.dart' as lib;
import 'package:http_parser/http_parser.dart';

import '../i_http_source.dart';

final Map<String, String> _defaultHeaders = {
  'Content-Type': 'application/json'
};
const int _maxImageSizeInBytes = 1024 * 1024;

class HttpSource implements IHttpSource {
  final lib.Client client;

  HttpSource({required this.client});

  @override
  Future<IHttpResponse> delete({required Uri uri, dynamic body}) async {
    var response = await client.delete(
      uri,
      body: body,
      headers: body == null ? null : _defaultHeaders,
    );

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
  Future<Uint8List> getBytes({required Uri uri}) async {
    var response = await client.get(uri);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Erro ${response.statusCode} ao baixar conteúdo de $uri',
        statusCode: response.statusCode,
        apiMessage: _extractApiMessageDeBytes(response.bodyBytes),
      );
    }
    return response.bodyBytes;
  }

  /// Extrai a mensagem de erro do corpo de uma resposta binaria que falhou
  /// (ex: erro JSON do backend numa rota que normalmente devolve PDF) --
  /// mesma logica de `RemoteDataSourceBase._extractApiMessage`, mas
  /// operando direto sobre bytes (getBytes nao decodifica o corpo como
  /// JSON no caminho de sucesso, pra nao corromper binario).
  String? _extractApiMessageDeBytes(Uint8List bytes) {
    if (bytes.isEmpty) return null;
    String texto;
    try {
      texto = utf8.decode(bytes);
    } catch (_) {
      return null;
    }

    dynamic body;
    try {
      body = jsonDecode(texto);
    } catch (_) {
      return texto.trim().isEmpty ? null : texto.trim();
    }

    if (body is Map) {
      final dynamic raw = body['message'] ?? body['error'] ?? body['errors'];
      if (raw == null) return null;
      final resultado = raw is List ? raw.join(' ') : raw.toString();
      return resultado.trim().isEmpty ? null : resultado.trim();
    }

    return null;
  }

  @override
  Future<IHttpResponse> post({
    required dynamic body,
    required Uri uri,
  }) async {
    log(body);
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

  @override
  Future<IHttpResponse> patch({required body, required Uri uri}) async {
    log(jsonEncode(body));
    var response = await client.patch(
      uri,
      body: jsonEncode(body),
      headers: _defaultHeaders,
    );

    return HttpResponse(response: response);
  }

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
  }) async {
    onSendProgress?.call(0, 100);

    var request = lib.MultipartRequest(
      'POST',
      uri,
    );
    if (headers != null) {
      request.headers.addAll(headers);
    }
    if (body != null) {
      request.fields.addAll(
        body.map((key, value) {
          if (value == null) {
            return MapEntry(key, '');
          }

          if (value is String) {
            return MapEntry(key, value);
          }

          return MapEntry(key, jsonEncode(value));
        }),
      );
    }

    final uploadBytes = fileType == FileType.image && compressImage
        ? _comprimirImagemParaUpload(bytes)
        : bytes;

    onSendProgress?.call(25, 100);

    request.files.add(
      lib.MultipartFile.fromBytes(
        field.trim().isEmpty ? 'file' : field,
        uploadBytes,
        filename: fileName,
        contentType: fileType == FileType.image
            ? MediaType('image', _mimeTypeFromFileName(fileName))
            : null,
      ),
    );

    onSendProgress?.call(55, 100);

    final response = await client.send(request);

    onSendProgress?.call(85, 100);

    var responseFinal = await lib.Response.fromStream(response);
    onSendProgress?.call(100, 100);
    log('${responseFinal.body} - ${responseFinal.statusCode}',
        name: 'Resposta do upload');
    return HttpResponse(response: responseFinal);
  }
}

/// Comprime/reencoda a imagem em JPEG até caber em [_maxImageSizeInBytes],
/// puro Dart (`package:image`) -- funciona em qualquer plataforma incl. web.
///
/// ponytail: roda síncrono na thread principal (sem `Isolate.run`, que não
/// existe no web -- lança `UnsupportedError` lá). Pode travar a UI por um
/// instante em fotos muito grandes; migrar pra Web Worker/isolate nativo se
/// isso virar reclamação real.
Uint8List _comprimirImagemParaUpload(Uint8List bytes) {
  if (bytes.length <= _maxImageSizeInBytes) {
    return bytes;
  }

  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    return bytes;
  }

  var workingImage = decoded;
  var quality = 90;
  Uint8List? bestResult;

  for (var attempt = 0; attempt < 12; attempt++) {
    final encoded = Uint8List.fromList(
      img.encodeJpg(workingImage, quality: quality),
    );
    bestResult = encoded;
    if (encoded.length <= _maxImageSizeInBytes) {
      return encoded;
    }

    if (workingImage.width > 900 || workingImage.height > 900) {
      workingImage = img.copyResize(
        workingImage,
        width: (workingImage.width * 0.8).round(),
        height: (workingImage.height * 0.8).round(),
      );
    }

    if (quality > 35) {
      quality -= 10;
    } else {
      break;
    }
  }

  return bestResult ?? bytes;
}

String _mimeTypeFromFileName(String fileName) {
  final dotIndex = fileName.lastIndexOf('.');
  final extensao =
      dotIndex == -1 ? '' : fileName.substring(dotIndex).toLowerCase();
  switch (extensao) {
    case '.jpg':
    case '.jpeg':
      return 'jpeg';
    case '.png':
      return 'png';
    case '.webp':
      return 'webp';
    default:
      return 'jpeg';
  }
}
