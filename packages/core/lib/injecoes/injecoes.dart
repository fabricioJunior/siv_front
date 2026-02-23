import 'package:core/injecoes/api_base_url_config.dart';
import 'package:core/remote_data_sourcers.dart';
import 'package:get_it/get_it.dart';

GetIt sl = GetIt.instance;

void coreInjections() {
  sl.registerFactory<IInformacoesParaRequests>(
    () => InformacoesParaRequest(
      httpSource: sl(),
      apiBaseUrlConfig: sl(),
    ),
  );

  sl.registerLazySingleton<ApiBaseUrlConfig>(() => ApiBaseUrlConfig());
}

class InformacoesParaRequest implements IInformacoesParaRequests {
  final IHttpSource httpSource;
  final ApiBaseUrlConfig apiBaseUrlConfig;

  InformacoesParaRequest(
      {required this.httpSource, required this.apiBaseUrlConfig});

  @override
  IHttpSource get httpClient => httpSource;

  @override
  Uri get uriBase => Uri.parse(
        apiBaseUrlConfig.urlBase,
      );
}
