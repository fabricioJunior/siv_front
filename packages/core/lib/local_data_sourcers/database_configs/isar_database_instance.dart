import 'dart:io';

import 'package:core/local_data_sourcers/isar/isar_configuracoes.dart';
import 'package:isar_community/isar.dart';

import 'i_isar_database_instance.dart';

class IsarDatabaseInstance implements IIsarDatabaseInstance {
  final List<Isar> _openedInstances = <Isar>[];

  @override
  List<Isar> get openedInstances => List<Isar>.unmodifiable(_openedInstances);

  @override
  Future<Isar> getIsar({
    required List<CollectionSchema<dynamic>> schemas,
    String? moduleName,
    bool isSyncData = false,
    bool isCommonData = false,
    bool showInspection = false,
  }) async {
    final instanceName = moduleName ??
        '${isSyncData ? 'sync_' : ''}${isCommonData ? 'common_data' : ''}';

    final currentInstance = Isar.getInstance(instanceName);
    if (currentInstance != null) {
      _registerOpenedInstance(currentInstance);
      return currentInstance;
    }
    if (isarDirectory == null) {
      await initIsarDatabase();
    }
    final rootDirectory = isarDirectory;

    final directory = Directory('${rootDirectory!.path}/$instanceName');
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    final instance = Isar.getInstance(instanceName) ??
        Isar.openSync(
          schemas,
          name: instanceName,
          directory: directory.path,
          inspector: showInspection,
        );

    _registerOpenedInstance(instance);

    return instance;
  }

  void _registerOpenedInstance(Isar instance) {
    if (!_openedInstances.contains(instance)) {
      _openedInstances.add(instance);
    }
  }

  @override
  Future<void> closeAllInstances() async {
    final instances = List<Isar>.from(_openedInstances);

    for (final instance in instances) {
      instance.close();
    }

    _openedInstances.clear();
  }

  @override
  Future<void> apagarTodosOsDados() async {
    final instances = List<Isar>.from(_openedInstances);

    for (final instance in instances) {
      await instance.close();
    }

    _openedInstances.clear();

    // Apaga o diretório raiz inteiro (não só as instâncias já abertas nesta
    // execução) -- se o app foi reiniciado sem nunca ter aberto algum
    // módulo, apagar só `_openedInstances` deixaria o arquivo antigo no
    // disco pra ser reaberto com dados do licenciado anterior no próximo
    // `getIsar`.
    final directory = isarDirectory;
    if (directory != null && directory.existsSync()) {
      await directory.delete(recursive: true);
    }
  }
}
