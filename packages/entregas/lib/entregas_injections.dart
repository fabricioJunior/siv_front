import 'package:core/injecoes.dart';
import 'package:entregas/data.dart';
import 'package:entregas/presentation.dart';
import 'package:entregas/use_cases.dart';

void resolverEntregasInjections() {
  _remoteDataSources();
  _repositories();
  _useCases();
  _presentation();
}

void _remoteDataSources() {
  sl.registerFactory<IIntegracaoEntregaRemoteDataSource>(
    () => IntegracaoEntregaRemoteDataSource(informacoesParaRequest: sl()),
  );
  sl.registerFactory<IFreteRemoteDataSource>(
    () => FreteRemoteDataSource(informacoesParaRequest: sl()),
  );
}

void _repositories() {
  sl.registerFactory<IFreteRepository>(
    () => FreteRepository(remoteDataSource: sl()),
  );
  sl.registerFactory<IIntegracaoEntregaRepository>(
    () => IntegracaoEntregaRepository(remoteDataSource: sl()),
  );
}

void _useCases() {
  sl.registerFactory<RecuperarConfiguracaoFrete>(
    () => RecuperarConfiguracaoFrete(repository: sl()),
  );
  sl.registerFactory<ListarTransportadorasFrete>(
    () => ListarTransportadorasFrete(repository: sl()),
  );
  sl.registerFactory<SalvarTransportadorasFrete>(
    () => SalvarTransportadorasFrete(repository: sl()),
  );
  sl.registerFactory<RecuperarConfiguracaoEntrega>(
    () => RecuperarConfiguracaoEntrega(repository: sl()),
  );
  sl.registerFactory<SalvarConfiguracaoEntrega>(
    () => SalvarConfiguracaoEntrega(repository: sl()),
  );
  sl.registerFactory<EstimarEntrega>(
    () => EstimarEntrega(repository: sl()),
  );
  sl.registerFactory<ObterSaldoEntrega>(
    () => ObterSaldoEntrega(repository: sl()),
  );
  sl.registerFactory<AbrirSolicitacaoEntrega>(
    () => AbrirSolicitacaoEntrega(repository: sl()),
  );
  sl.registerFactory<ObterRastreioEntrega>(
    () => ObterRastreioEntrega(repository: sl()),
  );
  sl.registerFactory<CancelarSolicitacaoEntrega>(
    () => CancelarSolicitacaoEntrega(repository: sl()),
  );
}

void _presentation() {
  sl.registerFactory<ConfiguracaoFreteBloc>(
    () => ConfiguracaoFreteBloc(sl(), sl(), sl()),
  );
  sl.registerFactory<ConfiguracaoEntregaBloc>(
    () => ConfiguracaoEntregaBloc(sl(), sl()),
  );
  sl.registerFactory<ChamarEntregadorBloc>(
    () => ChamarEntregadorBloc(sl(), sl(), sl(), sl(), sl(), sl(), sl()),
  );
}
