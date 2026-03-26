import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

abstract class ICacheImagemService {
  Future<void> deleteImagemComCacheKey(String cacheKey);

  Future<File?> getImagemFileFromCache(String cacheKey);

  Future<void> updateImageInCache(String cacheKey, String url);

  BaseCacheManager get cacheManager;
}

class CacheImagemService implements ICacheImagemService {
  @override
  Future<void> deleteImagemComCacheKey(String cacheKey) async {
    await cacheManager.removeFile(cacheKey);
  }

  @override
  Future<void> updateImageInCache(String cacheKey, String url) async {
    await deleteImagemComCacheKey(cacheKey);
    await cacheManager.removeFile(url);
    await cacheManager.downloadFile(
      url,
      key: cacheKey,
      force: true,
    );
  }

  @override
  Future<File?> getImagemFileFromCache(String cacheKey) async {
    final fileInfo =
        await cacheManager.getFileFromCache(cacheKey, ignoreMemCache: true);
    return fileInfo?.file;
  }

  @override
  final BaseCacheManager cacheManager = DefaultCacheManager();
}
