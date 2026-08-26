import 'package:core/injecoes.dart';
import 'package:core/local_data_sourcers/database_configs/i_hive_database_instance.dart';
import 'package:core/local_data_sourcers/hive/storage_entity_adapter.dart';
import 'package:estoque/domain/data/datasourcers/i_produtos_estoque_local_datasource.dart';
import 'package:hive_ce/hive.dart';

import 'dtos/produto_estoque_hive_dto.dart';
import 'produtos_estoque_hive_datasource.dart';

void registerProdutosEstoqueLocalDataSource() {
  sl.registerFactory<IProdutoEstoqueLocalDataSource>(
    () => ProdutosEstoqueHiveDatasource(getBox: _getBox),
  );
}

Future<Box<ProdutoEstoqueHiveDto>> _getBox() {
  return sl<IHiveDatabaseInstance>().getBox<ProdutoEstoqueHiveDto>(
    boxKey: 'ProdutoEstoqueHiveDto',
    adapters: [
      StorageEntityAdapter<ProdutoEstoqueHiveDto>(
        ProdutoEstoqueHiveDto.fromStorage,
      ),
    ],
    isCommonData: true,
    moduleName: 'estoque',
  );
}
