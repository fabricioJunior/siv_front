import 'dart:io';
import 'dart:ui' as ui;

import 'package:core/injecoes/injecoes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'cache_imagem_service.dart';

class ImagemViewWidget extends StatelessWidget {
  final String url;
  final String cacheKey;
  final bool onlyFromCache;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const ImagemViewWidget({
    super.key,
    required this.url,
    required this.cacheKey,
    this.onlyFromCache = false,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  static ImageProvider provider(String url, {String? cacheKey}) {
    return CachedNetworkImageProvider(url, cacheKey: cacheKey);
  }

  static ImageProvider imageInCacheProvider({required String cacheKey}) {
    return _ImageLocalProvider('', cacheKey);
  }

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return errorWidget ?? const Icon(Icons.error);
    }

    if (onlyFromCache) {
      if (cacheKey.isEmpty) {
        return errorWidget ?? const Icon(Icons.error);
      }

      return FutureBuilder<File?>(
        future: getImageFileFromCache(cacheKey),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return placeholder ??
                const Center(child: CircularProgressIndicator());
          }

          final file = snapshot.data;
          if ((file?.path.contains('html') ?? false) &&
              onlyFromCache &&
              placeholder != null) {
            return placeholder!;
          }
          if (file == null || file.path.contains('html')) {
            return errorWidget ?? const Icon(Icons.error);
          }

          return Image.file(file, fit: fit);
        },
      );
    }
    return Image(image: _ImageLocalProvider(url, cacheKey));
  }

  Future<File?> getImageFileFromCache(String cacheKey) async {
    return sl<ICacheImagemService>().getImagemFileFromCache(cacheKey);
  }
}

class _ImageLocalProvider extends ImageProvider<_ImageLocalProvider> {
  final String url;
  final String cacheKey;

  const _ImageLocalProvider(this.url, this.cacheKey);

  @override
  Future<_ImageLocalProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<_ImageLocalProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    _ImageLocalProvider key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: 1,
      debugLabel: cacheKey,
      informationCollector: () => [
        ErrorDescription('Cache key: $cacheKey'),
      ],
    );
  }

  Future<ui.Codec> _loadAsync(
    _ImageLocalProvider key,
    ImageDecoderCallback decode,
  ) async {
    var file =
        await sl<ICacheImagemService>().getImagemFileFromCache(key.cacheKey);
    if (file == null) {
      await sl<ICacheImagemService>().updateImageInCache(key.cacheKey, key.url);
      file =
          await sl<ICacheImagemService>().getImagemFileFromCache(key.cacheKey);
      if (file == null) {
        throw StateError('Erro a baixa a imagem ${key.cacheKey}');
      }
    }

    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw StateError(
          'Arquivo de imagem vazio no cache para a chave: ${key.cacheKey}');
    }

    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    return decode(buffer);
  }

  @override
  bool operator ==(Object other) {
    return other is _ImageLocalProvider && other.cacheKey == cacheKey;
  }

  @override
  int get hashCode => cacheKey.hashCode;
}
