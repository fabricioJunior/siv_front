import 'package:core/local_data_sourcers/database_configs/i_indexeddb_database_instance.dart';
import 'package:core/local_data_sourcers/database_configs/indexeddb_database_instance.dart';
import 'package:core/local_data_sourcers/hive/hive_dto.dart';
import 'package:core/local_data_sourcers/hive/storage_entity.dart';
import 'package:core/local_data_sourcers/indexeddb/indexeddb_local_data_source_base.dart';
import 'package:core/local_data_sourcers/indexeddb/indexeddb_schema.dart';
import 'package:idb_shim/idb_shim.dart';
import 'package:flutter_test/flutter_test.dart';

class _ItemDto with HiveDto<_ItemDto>, StorageEntity {
  _ItemDto({required this.id, required this.grupoId, required this.nome});

  final int id;
  final int grupoId;
  final String nome;

  @override
  int get dataBaseId => id;

  @override
  Map<String, dynamic> get storageProperties =>
      {'id': id, 'grupoId': grupoId, 'nome': nome};

  static _ItemDto fromStorage(Map<String, dynamic> props) => _ItemDto(
        id: props['id'] as int,
        grupoId: props['grupoId'] as int,
        nome: props['nome'] as String,
      );
}

class _ItemDataSource extends IndexedDbLocalDataSourceBase<_ItemDto, _ItemDto> {
  _ItemDataSource({required super.getDb})
      : super(storeName: 'itens_teste', fromStorage: _ItemDto.fromStorage);

  @override
  _ItemDto toDto(_ItemDto entity) => entity;
}

void main() {
  late IIndexedDbDatabaseInstance dbInstance;
  late _ItemDataSource dataSource;

  setUp(() {
    dbInstance = IndexedDbDatabaseInstance(
      factory: newIdbFactoryMemory(),
      stores: const [
        IndexedDbStoreSpec(storeName: 'itens_teste', indexes: ['grupoId']),
      ],
      version: 1,
    );
    dataSource = _ItemDataSource(getDb: () => dbInstance.getDatabase());
  });

  tearDown(() async {
    await dbInstance.closeAllInstances();
  });

  test('put + fetchById + fetchAll + deleteById + deleteAll', () async {
    await dataSource.put(_ItemDto(id: 1, grupoId: 10, nome: 'a'));
    await dataSource.putAll([
      _ItemDto(id: 2, grupoId: 10, nome: 'b'),
      _ItemDto(id: 3, grupoId: 20, nome: 'c'),
    ]);

    expect((await dataSource.fetchById(2))?.nome, 'b');
    expect((await dataSource.fetchAll()).length, 3);

    await dataSource.deleteById(1);
    expect(await dataSource.fetchById(1), isNull);
    expect((await dataSource.fetchAll()).length, 2);

    await dataSource.deleteAll();
    expect((await dataSource.fetchAll()).length, 0);
  });

  test('fetchWhere faz scan sobre todos os itens', () async {
    await dataSource.putAll([
      _ItemDto(id: 1, grupoId: 10, nome: 'a'),
      _ItemDto(id: 2, grupoId: 20, nome: 'b'),
    ]);

    final resultado = await dataSource.fetchWhere((dto) => dto.grupoId == 20);
    expect(resultado.map((e) => e.id), [2]);
  });

  test('fetchByIndex reflete put (update de valor indexado) e delete', () async {
    await dataSource.putAll([
      _ItemDto(id: 1, grupoId: 10, nome: 'a'),
      _ItemDto(id: 2, grupoId: 10, nome: 'b'),
      _ItemDto(id: 3, grupoId: 20, nome: 'c'),
    ]);

    var doGrupo10 = await dataSource.fetchByIndex('grupoId', 10);
    expect(doGrupo10.map((e) => e.id).toSet(), {1, 2});

    // Muda item 2 pro grupo 20 -- índice tem que refletir o novo valor e
    // sumir do bucket antigo.
    await dataSource.put(_ItemDto(id: 2, grupoId: 20, nome: 'b'));
    doGrupo10 = await dataSource.fetchByIndex('grupoId', 10);
    expect(doGrupo10.map((e) => e.id).toSet(), {1});

    var doGrupo20 = await dataSource.fetchByIndex('grupoId', 20);
    expect(doGrupo20.map((e) => e.id).toSet(), {2, 3});

    await dataSource.deleteById(3);
    doGrupo20 = await dataSource.fetchByIndex('grupoId', 20);
    expect(doGrupo20.map((e) => e.id).toSet(), {2});
  });
}
