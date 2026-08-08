import 'package:core/injecoes.dart';
import 'package:promocoes/data.dart';
import 'package:promocoes/presentation.dart';
import 'package:promocoes/use_cases.dart';

void resolverPromocoesInjections() {
  _remoteDataSources();
  _repositories();
  _useCases();
  _presentation();
}

void _remoteDataSources() {
  sl.registerFactory<IPromocoesRemoteDataSource>(
    () => PromocoesRemoteDataSource(informacoesParaRequest: sl()),
  );

  sl.registerFactory<ICuponsRemoteDataSource>(
    () => CuponsRemoteDataSource(informacoesParaRequest: sl()),
  );

  sl.registerFactory<IElegibilidadeRemoteDataSource>(
    () => ElegibilidadeRemoteDataSource(informacoesParaRequest: sl()),
  );
}

void _repositories() {
  sl.registerFactory<IPromocoesRepository>(
    () => PromocoesRepository(remoteDataSource: sl()),
  );

  sl.registerFactory<ICuponsRepository>(
    () => CuponsRepository(remoteDataSource: sl()),
  );

  sl.registerFactory<IElegibilidadeRepository>(
    () => ElegibilidadeRepository(remoteDataSource: sl()),
  );
}

void _useCases() {
  sl.registerFactory<RecuperarPromocoes>(
    () => RecuperarPromocoes(repository: sl()),
  );

  sl.registerFactory<RecuperarPromocao>(
    () => RecuperarPromocao(repository: sl()),
  );

  sl.registerFactory<CriarPromocao>(
    () => CriarPromocao(repository: sl()),
  );

  sl.registerFactory<AtualizarPromocao>(
    () => AtualizarPromocao(repository: sl()),
  );

  sl.registerFactory<RecuperarCupons>(
    () => RecuperarCupons(repository: sl()),
  );

  sl.registerFactory<RecuperarCupom>(
    () => RecuperarCupom(repository: sl()),
  );

  sl.registerFactory<CriarCupom>(
    () => CriarCupom(repository: sl()),
  );

  sl.registerFactory<AtualizarCupom>(
    () => AtualizarCupom(repository: sl()),
  );

  sl.registerFactory<ApurarElegibilidade>(
    () => ApurarElegibilidade(repository: sl()),
  );
}

void _presentation() {
  sl.registerFactory<PromocoesBloc>(
    () => PromocoesBloc(sl()),
  );

  sl.registerFactory<PromocaoBloc>(
    () => PromocaoBloc(sl(), sl(), sl(), sl()),
  );

  sl.registerFactory<CuponsBloc>(
    () => CuponsBloc(sl()),
  );

  sl.registerFactory<CupomBloc>(
    () => CupomBloc(sl(), sl(), sl()),
  );
}
