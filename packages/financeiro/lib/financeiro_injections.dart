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
  sl.registerFactory<ICaixaRemoteDataSource>(
    () => CaixaRemoteDataSource(
      informacoesParaRequest: sl(),
    ),
  );

  sl.registerFactory<IExtratoCaixaRemoteDataSource>(
    () => ExtratoCaixaRemoteDataSource(
      informacoesParaRequest: sl(),
    ),
  );

  sl.registerFactory<IFormasDePagamentoRemoteDataSource>(
    () => FormasDePagamentoRemoteDataSource(
      informacoesParaRequest: sl(),
    ),
  );

  sl.registerFactory<ISuprimentosRemoteDataSource>(
    () => SuprimentosRemoteDataSource(
      informacoesParaRequest: sl(),
    ),
  );
}

void _repositories() {
  sl.registerFactory<ICaixaRepository>(
    () => CaixaRepository(
      caixaRemoteDataSource: sl(),
      extratoCaixaRemoteDataSource: sl(),
    ),
  );

  sl.registerFactory<IFormasDePagamentoRepository>(
    () => FormasDePagamentoRepository(
      remoteDataSource: sl(),
    ),
  );

  sl.registerFactory<ISuprimentosRepository>(
    () => SuprimentosRepository(
      remoteDataSource: sl(),
    ),
  );
}

void _useCases() {
  sl.registerFactory<AbrirCaixa>(
    () => AbrirCaixa(repository: sl()),
  );

  sl.registerFactory<BuscarExtratoCaixa>(
    () => BuscarExtratoCaixa(repository: sl()),
  );

  sl.registerFactory<BuscarExtratoCaixaPorDocumento>(
    () => BuscarExtratoCaixaPorDocumento(repository: sl()),
  );

  sl.registerFactory<RecuperarCaixaAberto>(
    () => RecuperarCaixaAberto(repository: sl()),
  );

  sl.registerFactory<RecuperarFormasDePagamento>(
    () => RecuperarFormasDePagamento(repository: sl()),
  );

  sl.registerFactory<RecuperarFormaDePagamento>(
    () => RecuperarFormaDePagamento(repository: sl()),
  );

  sl.registerFactory<CriarFormaDePagamento>(
    () => CriarFormaDePagamento(repository: sl()),
  );

  sl.registerFactory<CriarSuprimento>(
    () => CriarSuprimento(repository: sl()),
  );

  sl.registerFactory<RecuperarSuprimento>(
    () => RecuperarSuprimento(repository: sl()),
  );

  sl.registerFactory<RecuperarSuprimentos>(
    () => RecuperarSuprimentos(repository: sl()),
  );

  sl.registerFactory<CancelarSuprimento>(
    () => CancelarSuprimento(repository: sl()),
  );

  sl.registerFactory<AtualizarFormaDePagamento>(
    () => AtualizarFormaDePagamento(repository: sl()),
  );
}

void _presentation() {
  sl.registerFactory<FluxoDeCaixaBloc>(
    () => FluxoDeCaixaBloc(
      sl(),
      sl(),
      sl(),
      sl(),
    ),
  );

  sl.registerFactory<SuprimentosBloc>(
    () => SuprimentosBloc(
      sl(),
      sl(),
    ),
  );

  sl.registerFactory<SuprimentoBloc>(
    () => SuprimentoBloc(
      sl(),
    ),
  );

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
