import 'package:core/hive_anotacoes.dart';
import 'package:core/injecoes.dart';
import 'package:core/local_data_sourcers/database_configs/i_hive_database_instance.dart';
import 'package:core/local_data_sourcers/hive/storage_entity_adapter.dart';

import 'dtos/relatorios_menu_prefs_hive_dto.dart';
import 'i_relatorios_menu_prefs_local_data_source.dart';

/// Comportamento idêntico ao que rodava antes inline em
/// `relatorios_menu_page.dart` -- só relocado pra trás de um seam
/// `_io`/`_web`, pra dar uma implementação web (IndexedDB) sem mudar nada
/// do nativo.
class RelatoriosMenuPrefsLocalDataSource
    implements IRelatoriosMenuPrefsLocalDataSource {
  @override
  Future<RelatoriosMenuPrefsHiveDto?> obter(int usuarioId) async {
    final box = await _getBox();
    return box.get(usuarioId);
  }

  @override
  Future<void> salvar(RelatoriosMenuPrefsHiveDto dto) async {
    final box = await _getBox();
    await box.put(dto.usuarioId, dto);
  }

  Future<Box<RelatoriosMenuPrefsHiveDto>> _getBox() {
    return sl<IHiveDatabaseInstance>().getBox<RelatoriosMenuPrefsHiveDto>(
      boxKey: 'RelatoriosMenuPrefsHiveDto',
      adapters: [
        StorageEntityAdapter<RelatoriosMenuPrefsHiveDto>(
          RelatoriosMenuPrefsHiveDto.fromStorage,
        ),
      ],
      isCommonData: true,
    );
  }
}
