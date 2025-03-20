import 'dart:io';
import 'package:path_provider/path_provider.dart' as path;

const String isarDirectoryPath = 'siv.isar';
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
