import 'package:core/injecoes.dart';
import 'package:core/local_data_sourcers/database_configs/i_hive_database_instance.dart';
import 'package:core/local_data_sourcers/hive/storage_entity_adapter.dart';
import 'package:hive_ce/hive.dart';
import 'package:produtos/domain/data/local/i_codigos_local_data_source.dart';

import 'codigos_hive_data_source.dart';
import 'dtos/codigo_hive_dto.dart';

void registerCodigosLocalDataSource() {
  sl.registerFactory<ICodigosLocalDataSource>(
    () => CodigosHiveDataSource(getBox: _getCodigoBox),
  );
}

Future<Box<CodigoHiveDto>> _getCodigoBox() {
  return sl<IHiveDatabaseInstance>().getBox<CodigoHiveDto>(
    boxKey: 'CodigoHiveDto',
    adapters: [StorageEntityAdapter<CodigoHiveDto>(CodigoHiveDto.fromStorage)],
    isCommonData: true,
    moduleName: 'produtos',
  );
}
