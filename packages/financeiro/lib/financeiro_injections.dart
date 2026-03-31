import 'package:core/injecoes.dart';
import 'package:financeiro/data.dart';
import 'package:financeiro/presentation.dart';
import 'package:financeiro/use_cases.dart';

void resolverFinanceiroInjections() {
  _remoteDataSources();
  _repositories();
  _useCases();
  _presentation();
}

void _remoteDataSources() {
  sl.registerFactory<IFormasDePagamentoRemoteDataSource>(
    () => FormasDePagamentoRemoteDataSource(
      informacoesParaRequest: sl(),
    ),
  );
}

void _repositories() {
  sl.registerFactory<IFormasDePagamentoRepository>(
    () => FormasDePagamentoRepository(
      remoteDataSource: sl(),
    ),
  );
}

void _useCases() {
  sl.registerFactory<RecuperarFormasDePagamento>(
    () => RecuperarFormasDePagamento(repository: sl()),
  );

  sl.registerFactory<RecuperarFormaDePagamento>(
    () => RecuperarFormaDePagamento(repository: sl()),
  );

  sl.registerFactory<CriarFormaDePagamento>(
    () => CriarFormaDePagamento(repository: sl()),
  );

  sl.registerFactory<AtualizarFormaDePagamento>(
    () => AtualizarFormaDePagamento(repository: sl()),
  );
}

void _presentation() {
  sl.registerFactory<FormasDePagamentoBloc>(
    () => FormasDePagamentoBloc(
      sl(),
    ),
  );

  sl.registerFactory<FormaDePagamentoBloc>(
    () => FormaDePagamentoBloc(
      sl(),
      sl(),
      sl(),
    ),
  );
}
