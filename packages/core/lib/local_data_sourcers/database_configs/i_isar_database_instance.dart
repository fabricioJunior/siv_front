import 'package:isar_community/isar.dart';

abstract class IIsarDatabaseInstance {
  Future<Isar> getIsar({
    required List<CollectionSchema<dynamic>> schemas,
    String? moduleName,
    bool isSyncData = false,
    bool isCommonData = false,
    bool showInspection = false,
  });

  List<Isar> get openedInstances;

  Future<void> closeAllInstances();

  /// Fecha todas as instâncias abertas e apaga o diretório raiz do Isar do
  /// disco. Usado no logout: dados locais não têm coluna de licenciadoId
  /// pra filtrar na leitura (diferente de empresaId, que os modelos já têm),
  /// então trocar de licenciado sem isso reabre o mesmo banco com dados do
  /// licenciado anterior ainda dentro.
  Future<void> apagarTodosOsDados();
}
