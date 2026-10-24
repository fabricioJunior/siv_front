import 'package:core/injecoes/injecoes.dart';
import 'package:core/local_data_sourcers/database_configs/i_hive_database_instance.dart';
import 'package:core/sessao.dart';
import 'package:hive_ce/hive.dart';

/// Contador local de uso de forma de pagamento por terminal, para ordenar a
/// grade da etapa de pagamento. Box Hive de inteiros (sem adapter/codegen);
/// falha de storage nunca derruba o pagamento.
class UsoFormasPagamento {
  static Future<Box<int>> _box() => sl<IHiveDatabaseInstance>().getBox<int>(
        boxKey: 'UsoFormasPagamento',
        adapters: const [],
        isCommonData: true,
      );

  static String _chave(int formaId) =>
      '${sl<IAcessoGlobalSessao>().terminalIdDaSessao ?? 0}:$formaId';

  /// formaId → vezes usada neste terminal.
  static Future<Map<int, int>> ler() async {
    try {
      final box = await _box();
      final prefixo = _chave(0).split(':').first;
      return {
        for (final k in box.keys)
          if (k is String && k.startsWith('$prefixo:'))
            int.parse(k.split(':').last): box.get(k) ?? 0,
      };
    } catch (_) {
      return {};
    }
  }

  static Future<void> registrar(Iterable<int> formaIds) async {
    try {
      final box = await _box();
      for (final id in formaIds.toSet()) {
        final chave = _chave(id);
        await box.put(chave, (box.get(chave) ?? 0) + 1);
      }
    } catch (_) {}
  }
}
