import 'dart:io';

import 'package:isar_community/isar.dart';

import 'package:path_provider/path_provider.dart' as path;

Id fastHash(String string) {
  var hash = 0xcbf29ce484222325;

  var i = 0;
  while (i < string.length) {
    final codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xFF;
    hash *= 0x100000001b3;
  }

  return hash;
}

const String isarDirectoryPath = 'mentor.isar';
Directory? isarDirectory;

Future<void> initIsarDatabase() async {
  await _initIsarDirectory();
}

Future<void> _initIsarDirectory() async {
  final dir = await path.getApplicationDocumentsDirectory();
  var directory = Directory('${dir.path}/$isarDirectoryPath');
  isarDirectory = directory;
  if (!directory.existsSync()) {
    await directory.create();
  }
}
