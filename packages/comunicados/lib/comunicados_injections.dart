import 'package:comunicados/data/remote/comunicado_remote_data_source.dart';
import 'package:comunicados/data/repositorios/comunicado_repository.dart';
import 'package:comunicados/domain/data/remote/i_comunicado_remote_data_source.dart';
import 'package:comunicados/domain/data/repositorios/i_comunicado_repository.dart';
import 'package:comunicados/domain/models/models.dart';
import 'package:comunicados/presentation.dart';
import 'package:comunicados/use_cases.dart';
import 'package:core/injecoes.dart';

void resolverComunicadosInjection() {
  _dataSources();
  _repositorios();
  _useCases();
  _presentation();
}

void _dataSources() {
  sl.registerFactory<IComunicadoRemoteDataSource>(
    () => ComunicadoRemoteDataSource(informacoesParaRequest: sl()),
  );
}

void _repositorios() {
  sl.registerFactory<IComunicadoRepository>(
    () => ComunicadoRepository(remoteDataSource: sl()),
  );
}

void _useCases() {
  sl.registerFactory<CriarComunicado>(() => CriarComunicado(repository: sl()));
  sl.registerFactory<ListarComunicados>(
    () => ListarComunicados(repository: sl()),
  );
  sl.registerFactory<BuscarComunicado>(
    () => BuscarComunicado(repository: sl()),
  );
  sl.registerFactory<ListarDestinatariosComunicado>(
    () => ListarDestinatariosComunicado(repository: sl()),
  );
  sl.registerFactory<ContarDestinatariosComunicado>(
    () => ContarDestinatariosComunicado(repository: sl()),
  );
  sl.registerFactory<PreviewDestinatariosComunicado>(
    () => PreviewDestinatariosComunicado(repository: sl()),
  );
  sl.registerFactory<ReenviarDestinatarioComunicado>(
    () => ReenviarDestinatarioComunicado(repository: sl()),
  );
  sl.registerFactory<EnviarImagemComunicado>(
    () => EnviarImagemComunicado(repository: sl()),
  );
}

void _presentation() {
  sl.registerFactory<ComunicadosBloc>(() => ComunicadosBloc(sl()));
  sl.registerFactory<DetalheComunicadoBloc>(
    () => DetalheComunicadoBloc(sl(), sl(), sl()),
  );
  sl.registerFactoryParam<
    ComposicaoComunicadoBloc,
    FiltroDestinatarioComunicado,
    void
  >(
    (filtroInicial, _) => ComposicaoComunicadoBloc(
      sl(),
      sl(),
      sl(),
      filtroInicial: filtroInicial,
    ),
  );
}
