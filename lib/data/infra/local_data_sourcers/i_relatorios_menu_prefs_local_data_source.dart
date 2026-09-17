import 'dtos/relatorios_menu_prefs_hive_dto.dart';

abstract interface class IRelatoriosMenuPrefsLocalDataSource {
  Future<RelatoriosMenuPrefsHiveDto?> obter(int usuarioId);

  Future<void> salvar(RelatoriosMenuPrefsHiveDto dto);
}
