import 'package:autenticacao/data.dart';
import 'package:core/injecoes.dart';
import 'package:core/local_data_sourcers/database_configs/i_indexeddb_database_instance.dart';

import 'empresa_da_sessao_indexeddb_data_source.dart';
import 'licenciado_da_sessao_indexeddb_data_source.dart';
import 'terminal_da_sessao_indexeddb_data_source.dart';
import 'usuario_da_sessao_indexeddb_data_source.dart';
import 'i_relatorios_menu_prefs_local_data_source.dart';
import 'relatorios_menu_prefs_local_data_source_web.dart';

void registerSessaoLocalDataSources() {
  sl.registerLazySingleton<IRelatoriosMenuPrefsLocalDataSource>(
    () => RelatoriosMenuPrefsLocalDataSource(),
  );

  sl.registerFactory<IUsuarioDaSessaoLocalDataSource>(
    () => UsuarioDaSessaoIndexedDbDataSource(
      getDb: () => sl<IIndexedDbDatabaseInstance>().getDatabase(),
    ),
  );

  sl.registerFactory<IEmpresaDaSessaoLocalDataSource>(
    () => EmpresaDaSessaoIndexedDbDataSource(
      getDb: () => sl<IIndexedDbDatabaseInstance>().getDatabase(),
    ),
  );
  sl.registerFactory<ILicenciadoDaSessaoLocalDataSource>(
    () => LicenciadoDaSessaoIndexedDbDataSource(
      getDb: () => sl<IIndexedDbDatabaseInstance>().getDatabase(),
    ),
  );

  sl.registerFactory<ITerminalDaSessaoLocalDataSource>(
    () => TerminalDaSessaoIndexedDbDataSource(
      getDb: () => sl<IIndexedDbDatabaseInstance>().getDatabase(),
    ),
  );
}
