import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:path/path.dart' as p;

import 'package:core/http/http_implementacao/http_response.dart';
import 'package:image/image.dart' as img;
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
const Set<String> _extensoesDeImagemPermitidas = {
  '.jpg',
  '.jpeg',
  '.png',
  '.webp',
};

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
    final uploadFile = fileType == FileType.image && compressImage
        ? await getCompressedFileForUpload(file.path) ?? file
        : file;

    onSendProgress?.call(25, 100);

    request.files.add(
      await lib.MultipartFile.fromPath(
        field.trim().isEmpty ? 'file' : field,
        uploadFile.path,
        contentType: fileType == FileType.image
            ? MediaType('image', _mimeTypeFromPath(uploadFile.path))
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

Future<File?> getCompressedFileForUpload(String path) async {
  final originalFile = await _normalizarFormatoDaImagem(path);
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
  var imageWidth = 1280;
  var imageHeight = 1280;

  try {
    final dimensoes = await _obterDimensoesDaImagemEmIsolate(bytes);
    if (dimensoes != null) {
      imageWidth = dimensoes['width'] ?? imageWidth;
      imageHeight = dimensoes['height'] ?? imageHeight;
    }
  } catch (_) {}

  var quality = 90;
  File? bestResult;

  for (var attempt = 0; attempt < 12; attempt++) {
    final outputPath =
        '${compressDir.path}/${DateTime.now().millisecondsSinceEpoch}_$attempt.jpg';

    try {
      final compressed = await FlutterImageCompress.compressAndGetFile(
        originalFile.path,
        outputPath,
        quality: quality,
        minWidth: imageWidth,
        minHeight: imageHeight,
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
    } catch (_) {
      break;
    }

    if (imageWidth > 900 || imageHeight > 900) {
      imageWidth =
          ((imageWidth * 0.8).round().clamp(1, imageWidth) as num).toInt();
      imageHeight =
          ((imageHeight * 0.8).round().clamp(1, imageHeight) as num).toInt();
    }
    if (quality > 35) {
      quality -= 10;
    } else {
      quality = 30;
    }
  }

  final fallbackFile = await _comprimirImagemComPureDart(
    bytes: bytes,
    outputDirectory: compressDir,
  );
  if (fallbackFile != null &&
      await fallbackFile.length() <= _maxImageSizeInBytes) {
    return fallbackFile;
  }

  if (bestResult != null && await bestResult.length() <= _maxImageSizeInBytes) {
    return bestResult;
  }

  throw Exception('Não foi possível comprimir a imagem para menos de 1MB.');
}

Future<File> _normalizarFormatoDaImagem(String path) async {
  final originalFile = File(path);
  if (!originalFile.existsSync()) {
    throw Exception('Imagem não encontrada para envio.');
  }

  final extensao = p.extension(path).toLowerCase();
  if (_extensoesDeImagemPermitidas.contains(extensao)) {
    return originalFile;
  }

  final tempDir = await getTemporaryDirectory();
  final normalizeDir = Directory('${tempDir.path}/siv_normalized');
  if (!normalizeDir.existsSync()) {
    normalizeDir.createSync(recursive: true);
  }

  final outputPath =
      '${normalizeDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

  try {
    final converted = await FlutterImageCompress.compressAndGetFile(
      originalFile.path,
      outputPath,
      quality: 95,
      format: CompressFormat.jpeg,
    );

    if (converted != null && File(converted.path).existsSync()) {
      return File(converted.path);
    }
  } catch (_) {}

  final bytes = await originalFile.readAsBytes();
  final arquivoConvertido = await _converterImagemParaJpegEmIsolate(
    bytes: bytes,
    outputPath: outputPath,
  );
  if (arquivoConvertido != null) {
    return arquivoConvertido;
  }

  throw Exception(
    'Formato de imagem não suportado. Use JPG, JPEG, PNG ou WEBP. Quando possível, a conversão é feita automaticamente antes do envio.',
  );
}

Future<File?> _comprimirImagemComPureDart({
  required Uint8List bytes,
  required Directory outputDirectory,
}) async {
  final encodedBytes = await Isolate.run<Uint8List?>(() {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return null;
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

    return bestResult;
  });

  if (encodedBytes == null) {
    return null;
  }

  final outputPath =
      '${outputDirectory.path}/${DateTime.now().millisecondsSinceEpoch}_fallback.jpg';
  final file = File(outputPath);
  await file.writeAsBytes(encodedBytes, flush: true);
  return file;
}

Future<Map<String, int>?> _obterDimensoesDaImagemEmIsolate(
  Uint8List bytes,
) async {
  return Isolate.run<Map<String, int>?>(() {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return null;
    }

    return {
      'width': decoded.width,
      'height': decoded.height,
    };
  });
}

Future<File?> _converterImagemParaJpegEmIsolate({
  required Uint8List bytes,
  required String outputPath,
}) async {
  final jpgBytes = await Isolate.run<Uint8List?>(() {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return null;
    }

    return Uint8List.fromList(img.encodeJpg(decoded, quality: 95));
  });

  if (jpgBytes == null) {
    return null;
  }

  final file = File(outputPath);
  await file.writeAsBytes(jpgBytes, flush: true);
  return file;
}

String _mimeTypeFromPath(String path) {
  final extensao = p.extension(path).toLowerCase();
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
