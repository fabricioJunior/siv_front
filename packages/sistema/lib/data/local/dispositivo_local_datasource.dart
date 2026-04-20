import 'dart:io';

import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:sistema/domain/data/data_sourcers/local/i_dispositivo_local_datasource.dart';
import 'package:sistema/domain/models/info_dispositivo.dart';

const String _isarDirectoryName = 'siv.isar';

class DispositivoLocalDataSource implements IDispositivoLocalDataSource {
  @override
  Future<InfoDispositivo> obterInfo() async {
    final docsDir = await path_provider.getApplicationDocumentsDirectory();
    final isarDir = Directory('${docsDir.path}/$_isarDirectoryName');

    int espacoUsadoBytes = 0;
    if (isarDir.existsSync()) {
      await for (final entity
          in isarDir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          try {
            espacoUsadoBytes += await entity.length();
          } catch (_) {}
        }
      }
    }

    String pathInstalacaoApp;
    try {
      pathInstalacaoApp = File(Platform.resolvedExecutable).parent.path;
    } catch (_) {
      pathInstalacaoApp = 'Não disponível';
    }

    return InfoDispositivo(
      espacoUsadoBytes: espacoUsadoBytes,
      pathBancoDeDados: isarDir.path,
      pathInstalacaoApp: pathInstalacaoApp,
    );
  }

  @override
  Future<void> apagarDadosLocais() async {
    final docsDir = await path_provider.getApplicationDocumentsDirectory();
    final isarDir = Directory('${docsDir.path}/$_isarDirectoryName');
    if (isarDir.existsSync()) {
      await isarDir.delete(recursive: true);
    }
  }
}
