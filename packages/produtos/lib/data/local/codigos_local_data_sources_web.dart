import 'package:core/injecoes.dart';
import 'package:core/local_data_sourcers/database_configs/i_indexeddb_database_instance.dart';
import 'package:produtos/domain/data/local/i_codigos_local_data_source.dart';

import 'codigos_indexeddb_data_source.dart';

void registerCodigosLocalDataSource() {
  sl.registerFactory<ICodigosLocalDataSource>(
    () => CodigosIndexedDbDataSource(
      getDb: () => sl<IIndexedDbDatabaseInstance>().getDatabase(),
    ),
  );
}
