import 'package:core/hive_anotacoes.dart';

/// DTO dos relatórios fixados pelo usuário (item "Fixados por você" de
/// `RelatoriosMenuPage`). Segue o padrão manual `StorageEntity`/`fromStorage`
/// de `lib/hive_storage_types.dart`, sem codegen. Chave = id do usuário
/// (preferência é por pessoa, não por empresa/terminal). Usado tanto no
/// lado nativo (Hive, ver `relatorios_menu_prefs_local_data_source_io.dart`)
/// quanto no web (IndexedDB, ver `..._web.dart`).
class RelatoriosMenuPrefsHiveDto implements HiveDto, StorageEntity {
  final int usuarioId;
  final List<String> rotasFixadas;

  RelatoriosMenuPrefsHiveDto({
    required this.usuarioId,
    this.rotasFixadas = const [],
  });

  @override
  int get dataBaseId => usuarioId;

  @override
  Map<String, dynamic> get storageProperties => {
    'usuarioId': usuarioId,
    'rotasFixadas': rotasFixadas,
  };

  static RelatoriosMenuPrefsHiveDto fromStorage(Map<String, dynamic> props) {
    return RelatoriosMenuPrefsHiveDto(
      usuarioId: props['usuarioId'] as int,
      rotasFixadas:
          (props['rotasFixadas'] as List?)?.cast<String>() ?? const [],
    );
  }
}
