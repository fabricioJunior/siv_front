import 'package:core/injecoes.dart';
import 'package:core/local_data_sourcers/database_configs/i_indexeddb_database_instance.dart';
import 'package:estoque/domain/data/datasourcers/i_produtos_estoque_local_datasource.dart';

import 'produtos_estoque_indexeddb_datasource.dart';

void registerProdutosEstoqueLocalDataSource() {
  sl.registerFactory<IProdutoEstoqueLocalDataSource>(
    () => ProdutosEstoqueIndexedDbDatasource(
      getDb: () => sl<IIndexedDbDatabaseInstance>().getDatabase(),
    ),
  );
}
