import 'dart:async';

import 'package:idb_shim/idb_shim.dart';

import '../indexeddb/indexeddb_schema.dart';
import 'i_indexeddb_database_instance.dart';

const _databaseName = 'siv_front_web';

class IndexedDbDatabaseInstance implements IIndexedDbDatabaseInstance {
  IndexedDbDatabaseInstance({
    IdbFactory? factory,
    List<IndexedDbStoreSpec> stores = indexedDbStores,
    int version = indexedDbSchemaVersion,
  })  : _factory = factory ?? idbFactoryWeb,
        _stores = stores,
        _version = version;

  final IdbFactory _factory;
  final List<IndexedDbStoreSpec> _stores;
  final int _version;
  Future<Database>? _opening;

  @override
  Future<Database> getDatabase() {
    return _opening ??= _open();
  }

  Future<Database> _open() async {
    final db = await _factory.open(
      _databaseName,
      version: _version,
      onUpgradeNeeded: (event) {
        final db = event.database;
        for (final spec in _stores) {
          final store = db.objectStoreNames.contains(spec.storeName)
              ? event.transaction.objectStore(spec.storeName)
              : db.createObjectStore(spec.storeName);
          for (final indexName in spec.indexes) {
            if (!store.indexNames.contains(indexName)) {
              store.createIndex(indexName, indexName);
            }
          }
          for (final indexName in spec.multiEntryIndexes) {
            if (!store.indexNames.contains(indexName)) {
              store.createIndex(indexName, indexName, multiEntry: true);
            }
          }
        }
      },
    );

    // Bancos antigos do Hive (um IndexedDB por box, mesmo nome de string
    // usado como boxKey) ficam órfãos após a migração -- best-effort,
    // nunca bloqueia o boot do app.
    unawaited(_apagarBancosHiveOrfaos());

    return db;
  }

  Future<void> _apagarBancosHiveOrfaos() async {
    for (final spec in _stores) {
      try {
        await _factory.deleteDatabase(spec.storeName);
      } catch (_) {
        // ponytail: best-effort, sem retry -- limpeza cosmética de disco.
      }
    }
  }

  @override
  Future<void> closeAllInstances() async {
    final db = await _opening;
    db?.close();
    _opening = null;
  }

  @override
  Future<void> apagarTodosOsDados() async {
    await closeAllInstances();
    await _factory.deleteDatabase(_databaseName);
  }
}
