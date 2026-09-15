import 'package:core/injecoes.dart';
import 'package:core/local_data_sourcers/database_configs/i_indexeddb_database_instance.dart';
import 'package:idb_shim/idb_shim.dart';

import 'dtos/relatorios_menu_prefs_hive_dto.dart';
import 'i_relatorios_menu_prefs_local_data_source.dart';

const _storeName = 'common_data_RelatoriosMenuPrefsHiveDto';

class RelatoriosMenuPrefsLocalDataSource
    implements IRelatoriosMenuPrefsLocalDataSource {
  @override
  Future<RelatoriosMenuPrefsHiveDto?> obter(int usuarioId) async {
    final db = await sl<IIndexedDbDatabaseInstance>().getDatabase();
    final txn = db.transaction(_storeName, idbModeReadOnly);
    final raw = await txn.objectStore(_storeName).getObject(usuarioId);
    await txn.completed;
    return raw == null
        ? null
        : RelatoriosMenuPrefsHiveDto.fromStorage(
            Map<String, dynamic>.from(raw as Map),
          );
  }

  @override
  Future<void> salvar(RelatoriosMenuPrefsHiveDto dto) async {
    final db = await sl<IIndexedDbDatabaseInstance>().getDatabase();
    final txn = db.transaction(_storeName, idbModeReadWrite);
    await txn.objectStore(_storeName).put(dto.storageProperties, dto.usuarioId);
    await txn.completed;
  }
}
