import 'package:idb_shim/idb_shim.dart';

import '../hive/hive_dto.dart';
import '../hive/storage_entity.dart';
import '../i_local_data_source.dart';

/// Contraparte de `HiveLocalDataSourceBase` pro engine IndexedDB (web).
/// Mesmo contrato ([ILocalDataSource]), mesma chave (`dataBaseId` de
/// [HiveDto]) -- só troca `Box<Dto>` por um object store versionado (ver
/// `indexeddb_schema.dart`). `fetchWhere` continua full-scan (igual Hive
/// hoje); use [fetchByIndex] nos campos declarados com índice no schema
/// pra busca O(log n) de verdade, sem carregar a store inteira em memória.
abstract class IndexedDbLocalDataSourceBase<Dto extends HiveDto, E>
    implements ILocalDataSource<Dto> {
  IndexedDbLocalDataSourceBase({
    required this.getDb,
    required this.storeName,
    required this.fromStorage,
  });

  final Future<Database> Function() getDb;
  final String storeName;
  final Dto Function(Map<String, dynamic>) fromStorage;

  @override
  Future<void> put(dynamic dto) async {
    final entity = dto is Dto ? dto : toDto(dto);
    final db = await getDb();
    final txn = db.transaction(storeName, idbModeReadWrite);
    await txn.objectStore(storeName).put(
          (entity as StorageEntity).storageProperties,
          entity.dataBaseId,
        );
    await txn.completed;
  }

  @override
  Future<void> putAll(Iterable<dynamic> entities) async {
    final dtos =
        entities is! Iterable<Dto> ? entities.map((e) => toDto(e)) : entities;
    final db = await getDb();
    final txn = db.transaction(storeName, idbModeReadWrite);
    final store = txn.objectStore(storeName);
    for (final dto in dtos) {
      await store.put((dto as StorageEntity).storageProperties, dto.dataBaseId);
    }
    await txn.completed;
  }

  @override
  Future<Dto?> fetchById(int id) async {
    final db = await getDb();
    final txn = db.transaction(storeName, idbModeReadOnly);
    final raw = await txn.objectStore(storeName).getObject(id);
    await txn.completed;
    return raw == null ? null : fromStorage(Map<String, dynamic>.from(raw as Map));
  }

  @override
  Future<Iterable<Dto>> fetchAll() async {
    final db = await getDb();
    final txn = db.transaction(storeName, idbModeReadOnly);
    final raws = await txn.objectStore(storeName).getAll();
    await txn.completed;
    return raws.map((raw) => fromStorage(Map<String, dynamic>.from(raw as Map)));
  }

  @override
  Future<Iterable<Dto>> fetchWhere(bool Function(Dto) predicate) async {
    return (await fetchAll()).where(predicate);
  }

  /// Busca via índice nativo do browser (declarado em `indexeddb_schema.dart`
  /// pro [storeName]) -- não carrega a store inteira, sem estrutura de
  /// índice mantida pela app.
  Future<Iterable<Dto>> fetchByIndex(String indexName, Object value) async {
    final db = await getDb();
    final txn = db.transaction(storeName, idbModeReadOnly);
    final raws = await txn.objectStore(storeName).index(indexName).getAll(value);
    await txn.completed;
    return raws.map((raw) => fromStorage(Map<String, dynamic>.from(raw as Map)));
  }

  /// Mesma ideia de [fetchByIndex], mas com um [KeyRange] -- usado pra busca
  /// por prefixo (`KeyRange.bound(termo, '$termo￿')`) num índice
  /// multiEntry, sem carregar a store inteira.
  Future<Iterable<Dto>> fetchByIndexRange(
    String indexName,
    KeyRange range,
  ) async {
    final db = await getDb();
    final txn = db.transaction(storeName, idbModeReadOnly);
    final raws = await txn.objectStore(storeName).index(indexName).getAll(range);
    await txn.completed;
    return raws.map((raw) => fromStorage(Map<String, dynamic>.from(raw as Map)));
  }

  Future<void> deleteById(int id) async {
    final db = await getDb();
    final txn = db.transaction(storeName, idbModeReadWrite);
    await txn.objectStore(storeName).delete(id);
    await txn.completed;
  }

  Future<void> deleteWhere(bool Function(Dto) predicate) async {
    final toDelete = await fetchWhere(predicate);
    for (final item in toDelete) {
      await deleteById(item.dataBaseId);
    }
  }

  @override
  Future<void> deleteAll() async {
    final db = await getDb();
    final txn = db.transaction(storeName, idbModeReadWrite);
    await txn.objectStore(storeName).clear();
    await txn.completed;
  }

  Dto toDto(E entity);
}
