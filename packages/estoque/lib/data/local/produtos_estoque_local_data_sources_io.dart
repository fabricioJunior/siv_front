import 'package:core/injecoes.dart';
import 'package:core/isar_anotacoes.dart';
import 'package:core/local_data_sourcers/database_configs/i_isar_database_instance.dart';
import 'package:estoque/domain/data/datasourcers/i_produtos_estoque_local_datasource.dart';

import 'dtos/produto_estoque_dto.dart';
import 'produtos_estoque_local_datasource.dart';

void registerProdutosEstoqueLocalDataSource() {
  sl.registerFactory<IProdutoEstoqueLocalDataSource>(
    () => ProdutosEstoqueLocalDatasource(getIsar: _getIsar),
  );
}

Future<Isar> _getIsar({bool? isSyncData}) async {
  var schemas = [ProdutoEstoqueDtoSchema];
  return sl<IIsarDatabaseInstance>().getIsar(
    schemas: schemas,
    isCommonData: true,
    isSyncData: isSyncData ?? false,
    moduleName: 'estoque',
    showInspection: true,
  );
}
