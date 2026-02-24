import 'package:core/injecoes.dart';
import 'package:sistema/data.dart';
import 'package:sistema/data/remote/configuracao_stmp_remote_datasource.dart';
import 'package:sistema/presentation/bloc/configuracao_stmp_bloc/configuracao_stmp_bloc.dart';
import 'package:sistema/uses_cases.dart';

void resolverSistemaInjections() {
  _remoteDataSources();
  _repositories();
  _useCases();
  _presentation();
}

void _remoteDataSources() {
  sl.registerFactory<IConfiguracaoSTMPRemoteDataSource>(
    () => ConfiguracaoSTMPRemoteDataSource(
      informacoesParaRequest: sl(),
    ),
  );
}

void _repositories() {
  sl.registerFactory<IConfiguracaoSTMPRepository>(
    () => ConfiguracaoSTMPRepository(
      remoteDataSource: sl(),
    ),
  );
}

void _useCases() {
  sl.registerFactory<RecuperarConfiguracaoSTMP>(
    () => RecuperarConfiguracaoSTMP(
      repository: sl(),
    ),
  );

  sl.registerFactory<CriarConfiguracaoSTMP>(
    () => CriarConfiguracaoSTMP(
      repository: sl(),
    ),
  );

  sl.registerFactory<AtualizarConfiguracaoSTMP>(
    () => AtualizarConfiguracaoSTMP(
      repository: sl(),
    ),
  );

  sl.registerFactory<VerificarConexaoSTMP>(
    () => VerificarConexaoSTMP(
      repository: sl(),
    ),
  );
}

void _presentation() {
  sl.registerFactory<ConfiguracaoSTMPBloc>(
    () => ConfiguracaoSTMPBloc(
      sl(),
      sl(),
      sl(),
      sl(),
    ),
  );
}
