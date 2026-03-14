import 'package:core/injecoes.dart';
import 'package:pagamentos/data.dart';
import 'package:pagamentos/presentation/bloc/pagamento_avulso_bloc/pagamento_avulso_bloc.dart';
import 'package:pagamentos/presentation/bloc/pagamentos_avulsos_bloc/pagamentos_avulsos_bloc.dart';
import 'package:pagamentos/use_cases.dart';

void resolverPagamentosInjections() {
  _remoteDataSources();
  _repositories();
  _useCases();
  _presentation();
}

void _remoteDataSources() {
  sl.registerFactory<IPagamentoAvulsoRemoteDataSource>(
    () => PagamentoAvulsoRemoteDataSource(
      informacoesParaRequest: sl(),
    ),
  );
}

void _repositories() {
  sl.registerFactory<IPagamentoAvulsoRepository>(
    () => PagamentoAvulsoRepository(
      remoteDataSource: sl(),
    ),
  );
}

void _useCases() {
  sl.registerFactory<CriarIdempotencyKey>(
    () => CriarIdempotencyKey(),
  );

  sl.registerFactory<RecuperarPagamentosAvulsos>(
    () => RecuperarPagamentosAvulsos(
      repository: sl(),
    ),
  );

  sl.registerFactory<CriarPagamentoAvulso>(
    () => CriarPagamentoAvulso(
      repository: sl(),
    ),
  );
}

void _presentation() {
  sl.registerFactory<PagamentosAvulsosBloc>(
    () => PagamentosAvulsosBloc(
      sl(),
    ),
  );

  sl.registerFactory<PagamentoAvulsoBloc>(
    () => PagamentoAvulsoBloc(
      sl(),
      sl(),
    ),
  );
}
