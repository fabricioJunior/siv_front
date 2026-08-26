import 'package:core/injecoes.dart';
import 'package:core/isar_anotacoes.dart';
import 'package:core/local_data_sourcers/database_configs/i_isar_database_instance.dart';
import 'package:produtos/domain/data/local/i_codigos_local_data_source.dart';

import 'codigos_local_data_source.dart';
import 'dtos/codigo_dto.dart';

void registerCodigosLocalDataSource() {
  sl.registerFactory<ICodigosLocalDataSource>(
    () => CodigosLocalDataSource(getIsar: _getIsar),
  );
}

Future<Isar> _getIsar({bool? isSyncData = false}) async {
  List<CollectionSchema<dynamic>> schemas = [CodigoDtoSchema];

  return sl<IIsarDatabaseInstance>().getIsar(
    schemas: schemas,
    isCommonData: true,
    isSyncData: isSyncData ?? false,
    moduleName: 'produtos',
    showInspection: true,
  );
}
