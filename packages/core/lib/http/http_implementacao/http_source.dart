import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:path/path.dart' as p;

import 'package:core/http/http_implementacao/http_response.dart';
import 'package:core/http/i_http_response.dart';
import 'package:http/http.dart' as lib;
import 'package:http_parser/http_parser.dart';

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
    required FileType fileType,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool compressImage = true,
  }) async {
    var request = lib.MultipartRequest(
      'POST',
      uri,
    );
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
    var comprressedFile = await getCompressedFileForUpload(file.path);
    request.files.add(
      await lib.MultipartFile.fromPath(
          'file', comprressedFile?.path ?? file.path,
          contentType:
              MediaType('image', p.extension(file.path).replaceFirst('.', ''))),
    );

    lib.StreamedResponse response = await client.send(request);

    var responseFinal = await lib.Response.fromStream(response);
    log('${responseFinal.body} - ${responseFinal.statusCode}',
        name: 'Resposta do upload');
    return HttpResponse(response: responseFinal);
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
