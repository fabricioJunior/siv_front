import 'package:hive_ce/hive.dart';

/// Preferências pequenas guardadas por aparelho (ex.: último funcionário da
/// entrada por contagem). Falha em silêncio: é só conveniência.
class PreferenciaLocal {
  static const _box = 'preferencias_locais';

  static Future<int?> lerInt(String chave) async {
    try {
      return (await Hive.openBox(_box)).get(chave) as int?;
    } catch (_) {
      return null;
    }
  }

  static Future<void> gravarInt(String chave, int valor) async {
    try {
      await (await Hive.openBox(_box)).put(chave, valor);
    } catch (_) {}
  }
}
