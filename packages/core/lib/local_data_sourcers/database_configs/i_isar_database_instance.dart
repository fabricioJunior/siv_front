import 'package:isar_community/isar.dart';

abstract class IIsarDatabaseInstance {
  Future<Isar> getIsar({
    required List<CollectionSchema<dynamic>> schemas,
    String? moduleName,
    bool isSyncData = false,
    bool isCommonData = false,
  });

  List<Isar> get openedInstances;

  Future<void> closeAllInstances();
}
