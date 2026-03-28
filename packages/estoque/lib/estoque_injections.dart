import 'package:core/injecoes.dart';
import 'package:estoque/data/remote/estoque_saldo_remote_data_source.dart';
import 'package:estoque/data/repositorios/estoque_repository.dart';
import 'package:estoque/domain/data/remote/i_estoque_saldo_remote_data_source.dart';
import 'package:estoque/domain/data/repositorios/i_estoque_repository.dart';
import 'package:estoque/presentation.dart';
import 'package:estoque/use_cases.dart';

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
}

void _repositorios() {
  sl.registerFactory<IEstoqueRepository>(
    () => EstoqueRepository(estoqueSaldoRemoteDataSource: sl()),
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
