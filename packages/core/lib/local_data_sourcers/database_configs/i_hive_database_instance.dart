import 'package:hive_ce/hive.dart';

import '../hive/storage_entity_adapter.dart';
import 'i_local_database_instance.dart';

abstract class IHiveDatabaseInstance implements ILocalDatabaseInstance {
  Future<Box<T>> getBox<T>({
    required List<StorageEntityAdapter> adapters,
    String? moduleName,
    bool isSyncData = false,
    bool isCommonData = false,
  });

  @override
  Future<void> closeAllInstances();

  @override
  Future<void> apagarTodosOsDados();
}
