import 'package:hive_ce/hive.dart';

import '../hive/storage_entity_adapter.dart';
import 'i_hive_database_instance.dart';

class HiveDatabaseInstance implements IHiveDatabaseInstance {
  final Map<String, Box<dynamic>> _openedBoxes = <String, Box<dynamic>>{};

  @override
  Future<Box<T>> getBox<T>({
    required List<StorageEntityAdapter> adapters,
    required String boxKey,
    String? moduleName,
    bool isSyncData = false,
    bool isCommonData = false,
  }) async {
    final instanceName = moduleName ??
        '${isSyncData ? 'sync_' : ''}${isCommonData ? 'common_data' : ''}';
    // boxKey precisa ser string literal, não `$T` -- Type.toString() é
    // instável em build web release/minificado e pode colidir entre DTOs.
    final boxName = '${instanceName}_$boxKey';

    final opened = _openedBoxes[boxName];
    if (opened != null) {
      return opened as Box<T>;
    }

    // Cada adapter registra a si mesmo (`registerHiveAdapterWithType`) --
    // precisa ser assim porque cada `StorageEntityAdapter<E>` conhece seu
    // próprio `E` estaticamente. Chamar `Hive.registerAdapter(adapter)` aqui
    // de fora, com `adapter` tipado como elemento de `List<StorageEntityAdapter>`
    // (E apagado), registra pra `dynamic` -- todas as boxes acabam
    // compartilhando o mesmo adapter "curinga", misturando os tipos entre si.
    for (final adapter in adapters) {
      adapter.registerHiveAdapterWithType();
    }

    final box = await Hive.openBox<T>(boxName);
    _openedBoxes[boxName] = box;

    return box;
  }

  @override
  Future<void> closeAllInstances() async {
    final boxes = List<Box<dynamic>>.from(_openedBoxes.values);

    for (final box in boxes) {
      await box.close();
    }

    _openedBoxes.clear();
  }

  @override
  Future<void> apagarTodosOsDados() async {
    final boxNames = List<String>.from(_openedBoxes.keys);

    for (final boxName in boxNames) {
      await Hive.deleteBoxFromDisk(boxName);
    }

    _openedBoxes.clear();
  }
}
