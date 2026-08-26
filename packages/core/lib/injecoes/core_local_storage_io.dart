import 'package:core/injecoes.dart';
import 'package:core/local_data_sourcers/database_configs/i_hive_database_instance.dart';
import 'package:core/local_data_sourcers/database_configs/i_isar_database_instance.dart';
import 'package:core/local_data_sourcers/database_configs/i_local_database_instance.dart';
import 'package:core/local_data_sourcers/database_configs/hive_database_instance.dart';
import 'package:core/local_data_sourcers/database_configs/isar_database_instance.dart';
import 'package:core/paginacao/i_paginacao_data_source.dart';
import 'package:core/paginacao/paginacao_data_source.dart';
import 'package:core/paginacao/paginacao_isar_dto.dart';
import 'package:core/produtos_compartilhados/local/dtos/lista_de_produtos_compartilhada_dto.dart';
import 'package:core/produtos_compartilhados/local/dtos/produto_compartilhado_dto.dart';
import 'package:core/produtos_compartilhados/local/i_lista_de_produtos_compartilhada_local_data_source.dart';
import 'package:core/produtos_compartilhados/local/i_produtos_compartilhados_local_data_source.dart';
import 'package:core/produtos_compartilhados/local/lista_de_produtos_compartilhada_local_data_source.dart';
import 'package:core/produtos_compartilhados/local/produtos_compartilhados_local_data_source.dart';
import 'package:isar_community/isar.dart';

void registerCoreLocalStorage() {
  // Singleton -- precisa acumular as instâncias Isar abertas
  // (`_openedInstances`) pra `closeAllInstances`/`apagarTodosOsDados`
  // funcionarem de verdade. Como factory, cada `sl()` criava um objeto novo
  // com a lista sempre vazia, e essas duas operações nunca fechavam/apagavam
  // nada de fato.
  sl.registerLazySingleton<IIsarDatabaseInstance>(() => IsarDatabaseInstance());
  sl.registerLazySingleton<IHiveDatabaseInstance>(() => HiveDatabaseInstance());
  sl.registerLazySingleton<ILocalDatabaseInstance>(
    () => sl<IIsarDatabaseInstance>(),
  );

  sl.registerLazySingleton<IListaDeProdutosCompartilhadaLocalDataSource>(
    () => ListaDeProdutosCompartilhadaLocalDataSource(getIsar: _getIsar),
  );

  sl.registerLazySingleton<IProdutosCompartilhadosLocalDataSource>(
    () => ProdutosCompartilhadosLocalDataSource(getIsar: _getIsar),
  );

  sl.registerFactory<IPaginacaoDataSource>(
    () => PaginacaoDataSource(getIsar: _getIsar),
  );
}

Future<Isar> _getIsar({bool? isSyncData = false}) async {
  List<CollectionSchema<dynamic>> schemas = [
    PaginacaoIsarDtoSchema,
    ProdutoCompartilhadoDtoSchema,
    ListaDeProdutosCompartilhadaDtoSchema,
  ];

  return sl<IIsarDatabaseInstance>().getIsar(
    schemas: schemas,
    isSyncData: isSyncData ?? false,
    isCommonData: true,
    moduleName: 'core',
  );
}
