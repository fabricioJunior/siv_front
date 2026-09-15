import 'package:core/data_sourcers.dart';
import 'package:core/injecoes.dart';
import 'package:precos/domain/data/local/i_precos_de_referencias_local_data_source.dart';
import 'package:precos/domain/data/local/i_tabelas_de_preco_local_data_source.dart';

import 'precos_de_referencias_indexeddb_data_source.dart';
import 'tabelas_de_preco_indexeddb_data_source.dart';

void registerPrecosLocalDataSources() {
  sl.registerFactory<ITabelasDePrecoLocalDataSource>(
    () => TabelasDePrecoIndexedDbDataSource(
      getDb: () => sl<IIndexedDbDatabaseInstance>().getDatabase(),
    ),
  );
  sl.registerFactory<IPrecosDeReferenciasLocalDataSource>(
    () => PrecosDeReferenciasIndexedDbDataSource(
      getDb: () => sl<IIndexedDbDatabaseInstance>().getDatabase(),
    ),
  );
}
