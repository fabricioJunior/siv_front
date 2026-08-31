import 'package:core/injecoes.dart';
import 'package:core/local_data_sourcers/database_configs/i_hive_database_instance.dart';
import 'package:core/local_data_sourcers/database_configs/i_local_database_instance.dart';
import 'package:core/local_data_sourcers/database_configs/hive_database_instance.dart';
import 'package:core/local_data_sourcers/hive/storage_entity_adapter.dart';
import 'package:core/paginacao/i_paginacao_data_source.dart';
import 'package:core/paginacao/paginacao_hive_data_source.dart';
import 'package:core/paginacao/paginacao_hive_dto.dart';
import 'package:core/produtos_compartilhados/local/dtos/lista_de_produtos_compartilhada_hive_dto.dart';
import 'package:core/produtos_compartilhados/local/dtos/produto_compartilhado_hive_dto.dart';
import 'package:core/produtos_compartilhados/local/i_lista_de_produtos_compartilhada_local_data_source.dart';
import 'package:core/produtos_compartilhados/local/i_produtos_compartilhados_local_data_source.dart';
import 'package:core/produtos_compartilhados/local/lista_de_produtos_compartilhada_hive_data_source.dart';
import 'package:core/produtos_compartilhados/local/produtos_compartilhados_hive_data_source.dart';
import 'package:hive_ce/hive.dart';

void registerCoreLocalStorage() {
  sl.registerLazySingleton<IHiveDatabaseInstance>(() => HiveDatabaseInstance());
  sl.registerLazySingleton<ILocalDatabaseInstance>(
    () => sl<IHiveDatabaseInstance>(),
  );

  sl.registerLazySingleton<IListaDeProdutosCompartilhadaLocalDataSource>(
    () => ListaDeProdutosCompartilhadaHiveDataSource(
      getBox: _getListaDeProdutosCompartilhadaBox,
    ),
  );

  sl.registerLazySingleton<IProdutosCompartilhadosLocalDataSource>(
    () => ProdutosCompartilhadosHiveDataSource(
      getBox: _getProdutosCompartilhadosBox,
    ),
  );

  sl.registerLazySingleton<IPaginacaoDataSource>(
    () => PaginacaoHiveDataSource(getBox: _getPaginacaoBox),
  );
}

Future<Box<PaginacaoHiveDto>> _getPaginacaoBox() {
  return sl<IHiveDatabaseInstance>().getBox<PaginacaoHiveDto>(
    boxKey: 'PaginacaoHiveDto',
    adapters: [
      StorageEntityAdapter<PaginacaoHiveDto>(PaginacaoHiveDto.fromStorage),
    ],
    isCommonData: true,
    moduleName: 'core',
  );
}

Future<Box<ProdutoCompartilhadoHiveDto>> _getProdutosCompartilhadosBox() {
  return sl<IHiveDatabaseInstance>().getBox<ProdutoCompartilhadoHiveDto>(
    boxKey: 'ProdutoCompartilhadoHiveDto',
    adapters: [
      StorageEntityAdapter<ProdutoCompartilhadoHiveDto>(
        ProdutoCompartilhadoHiveDto.fromStorage,
      ),
    ],
    isCommonData: true,
    moduleName: 'core',
  );
}

Future<Box<ListaDeProdutosCompartilhadaHiveDto>>
    _getListaDeProdutosCompartilhadaBox() {
  return sl<IHiveDatabaseInstance>()
      .getBox<ListaDeProdutosCompartilhadaHiveDto>(
    boxKey: 'ListaDeProdutosCompartilhadaHiveDto',
    adapters: [
      StorageEntityAdapter<ListaDeProdutosCompartilhadaHiveDto>(
        ListaDeProdutosCompartilhadaHiveDto.fromStorage,
      ),
    ],
    isCommonData: true,
    moduleName: 'core',
  );
}
