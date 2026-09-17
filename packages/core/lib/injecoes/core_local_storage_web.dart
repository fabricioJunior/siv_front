import 'package:core/injecoes.dart';
import 'package:core/local_data_sourcers/database_configs/hive_database_instance.dart';
import 'package:core/local_data_sourcers/database_configs/i_hive_database_instance.dart';
import 'package:core/local_data_sourcers/database_configs/i_indexeddb_database_instance.dart';
import 'package:core/local_data_sourcers/database_configs/i_local_database_instance.dart';
import 'package:core/local_data_sourcers/database_configs/indexeddb_database_instance.dart';
import 'package:core/paginacao/i_paginacao_data_source.dart';
import 'package:core/paginacao/paginacao_indexeddb_data_source.dart';
import 'package:core/produtos_compartilhados/local/i_lista_de_produtos_compartilhada_local_data_source.dart';
import 'package:core/produtos_compartilhados/local/i_produtos_compartilhados_local_data_source.dart';
import 'package:core/produtos_compartilhados/local/lista_de_produtos_compartilhada_indexeddb_data_source.dart';
import 'package:core/produtos_compartilhados/local/produtos_compartilhados_indexeddb_data_source.dart';

void registerCoreLocalStorage() {
  sl.registerLazySingleton<IIndexedDbDatabaseInstance>(
    () => IndexedDbDatabaseInstance(),
  );
  sl.registerLazySingleton<ILocalDatabaseInstance>(
    () => sl<IIndexedDbDatabaseInstance>(),
  );

  // Faltava aqui -- Hive.initFlutter() já roda pra todas as plataformas
  // (main.dart), inclusive web (hive_ce suporta), mas o registro no GetIt
  // só existia no branch io. Deslogar (autenticacao_injecoes.dart) exige
  // IHiveDatabaseInstance incondicionalmente, quebrando o boot inteiro na
  // web com "not registered inside GetIt".
  sl.registerLazySingleton<IHiveDatabaseInstance>(() => HiveDatabaseInstance());

  sl.registerLazySingleton<IListaDeProdutosCompartilhadaLocalDataSource>(
    () => ListaDeProdutosCompartilhadaIndexedDbDataSource(
      getDb: () => sl<IIndexedDbDatabaseInstance>().getDatabase(),
    ),
  );

  sl.registerLazySingleton<IProdutosCompartilhadosLocalDataSource>(
    () => ProdutosCompartilhadosIndexedDbDataSource(
      getDb: () => sl<IIndexedDbDatabaseInstance>().getDatabase(),
    ),
  );

  sl.registerLazySingleton<IPaginacaoDataSource>(
    () => PaginacaoIndexedDbDataSource(
      getDb: () => sl<IIndexedDbDatabaseInstance>().getDatabase(),
    ),
  );
}
