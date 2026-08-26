import 'package:isar_community/isar.dart';

import 'i_local_database_instance.dart';

abstract class IIsarDatabaseInstance implements ILocalDatabaseInstance {
  Future<Isar> getIsar({
    required List<CollectionSchema<dynamic>> schemas,
    String? moduleName,
    bool isSyncData = false,
    bool isCommonData = false,
    bool showInspection = false,
  });

  List<Isar> get openedInstances;

  @override
  Future<void> closeAllInstances();

  @override
  Future<void> apagarTodosOsDados();
}
