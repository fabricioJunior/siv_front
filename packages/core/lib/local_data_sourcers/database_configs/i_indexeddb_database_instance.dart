import 'package:idb_shim/idb_shim.dart';

import 'i_local_database_instance.dart';

abstract class IIndexedDbDatabaseInstance implements ILocalDatabaseInstance {
  /// Banco único, já aberto e migrado (todos os object stores/índices de
  /// [indexedDbStores] criados) -- ver `../indexeddb/indexeddb_schema.dart`.
  Future<Database> getDatabase();

  @override
  Future<void> closeAllInstances();

  @override
  Future<void> apagarTodosOsDados();
}
