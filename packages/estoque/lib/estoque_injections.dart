import 'package:core/injecoes.dart';
import 'package:core/isar_anotacoes.dart';
import 'package:core/local_data_sourcers/database_configs/i_isar_database_instance.dart';
import 'package:estoque/data/remote/estoque_saldo_remote_data_source.dart';
import 'package:estoque/data/repositorios/estoque_repository.dart';
import 'package:estoque/domain/data/datasourcers/i_produtos_estoque_local_datasource.dart';
import 'package:estoque/domain/data/remote/i_estoque_saldo_remote_data_source.dart';
import 'package:estoque/domain/data/repositorios/i_estoque_repository.dart';
import 'package:estoque/presentation.dart';
import 'package:estoque/use_cases.dart';

import 'data/local/dtos/produto_estoque_dto.dart';
import 'data/local/produtos_estoque_local_datasource.dart';

void resolverEstoqueInjection() {
  _dataSources();
  _repositorios();
  _useCases();
  _presentation();
}

void _dataSources() {
  sl.registerFactory<IEstoqueSaldoRemoteDataSource>(
    () => EstoqueSaldoRemoteDataSource(informacoesParaRequest: sl()),
  );
  sl.registerFactory<IProdutoEstoqueLocalDataSource>(
    () => ProdutosEstoqueLocalDatasource(getIsar: _getIsar),
  );
}

void _repositorios() {
  sl.registerFactory<IEstoqueRepository>(
    () => EstoqueRepository(
      estoqueSaldoRemoteDataSource: sl(),
      paginacaoDataSource: sl(),
      produtosEstoqueLocalDataSource: sl(),
    ),
  );
}

void _useCases() {
  sl.registerFactory<RecuperarSaldoDoEstoque>(
    () => RecuperarSaldoDoEstoque(estoqueRepository: sl()),
  );
}

void _presentation() {
  sl.registerFactory<EstoqueSaldoBloc>(() => EstoqueSaldoBloc(sl()));
}

Future<Isar> _getIsar({bool? isSyncData}) async {
  var schemas = [ProdutoEstoqueDtoSchema];
  return sl<IIsarDatabaseInstance>().getIsar(
    schemas: schemas,
    isCommonData: true,
    isSyncData: isSyncData ?? false,
  );
}
