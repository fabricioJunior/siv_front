import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:core/http/http_implementacao/http_response.dart';
import 'package:core/http/i_http_response.dart';
import 'package:http/http.dart' as lib;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

import '../i_http_source.dart';

final Map<String, String> _defaultHeaders = {
  'Content-Type': 'application/json'
};
const int _maxImageSizeInBytes = 1024 * 1024;

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
  Future<IHttpResponse> postMultipart({
    required Uri uri,
    required String field,
    required File file,
    Map<String, dynamic>? body,
    bool compressImage = true,
  }) async {
    var request = lib.MultipartRequest('POST', uri);

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
    String? filePath;
    if (compressImage) {
      try {
        filePath = (await getCompressedFileForUpload(file.path))?.path;
      } catch (e) {
        log('Erro ao comprimir imagem: $e');
        filePath = file.path;
      }
    } else {
      filePath = file.path;
    }

    if (filePath == null) {
      throw Exception('Não foi possível processar o arquivo para upload.');
    }

    var compressedFile = File(filePath);
    if (!compressedFile.existsSync()) {
      throw Exception('Arquivo para upload não encontrado.');
    }

    request.files
        .add(await lib.MultipartFile.fromPath(field, compressedFile.path));

    var streamedResponse = await client.send(request);
    var response = await lib.Response.fromStream(streamedResponse);
    return HttpResponse(response: response);
  }
}

Future<File?> getCompressedFileForUpload(String path) async {
  final originalFile = File(path);
  if (!originalFile.existsSync()) {
    return null;
  }

  final originalSize = await originalFile.length();
  if (originalSize <= _maxImageSizeInBytes) {
    return originalFile;
  }

  final tempDir = await getTemporaryDirectory();
  final compressDir = Directory('${tempDir.path}/siv_compress');
  if (!compressDir.existsSync()) {
    compressDir.createSync(recursive: true);
  }

  final bytes = await originalFile.readAsBytes();
  final image = await _decodeImage(bytes);
  var imageSize = Size(image.width.toDouble(), image.height.toDouble());
  var quality = 90;
  File? bestResult;

  for (var attempt = 0; attempt < 12; attempt++) {
    final outputPath =
        '${compressDir.path}/${DateTime.now().millisecondsSinceEpoch}_$attempt.jpg';

    final compressed = await FlutterImageCompress.compressAndGetFile(
      originalFile.path,
      outputPath,
      quality: quality,
      minWidth: imageSize.width.toInt(),
      minHeight: imageSize.height.toInt(),
      format: CompressFormat.jpeg,
    );

    if (compressed == null) {
      continue;
    }

    final compressedFile = File(compressed.path);
    if (!compressedFile.existsSync()) {
      continue;
    }

    bestResult = compressedFile;
    final compressedSize = await compressedFile.length();
    if (compressedSize <= _maxImageSizeInBytes) {
      return compressedFile;
    }

    if ((imageSize.width > 900 || imageSize.height > 900)) {
      imageSize = Size(imageSize.width * 0.8, imageSize.height * 0.8);
    }
    if (quality > 35) {
      quality -= 10;
    } else {
      quality = 30;
    }
  }

  if (bestResult != null && await bestResult.length() <= _maxImageSizeInBytes) {
    return bestResult;
  }

  throw Exception('Nao foi possivel comprimir a imagem para menos de 1MB.');
}

Future<Image> _decodeImage(Uint8List bytes) async {
  final codec = await instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  return frame.image;
}
