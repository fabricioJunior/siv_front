import 'package:core/remote_data_sourcers.dart';
import 'package:get_it/get_it.dart';

GetIt sl = GetIt.instance;

void coreInjections() {
  sl.registerFactory<IInformacoesParaRequests>(
    () => InformacoesParaRequest(
      httpSource: sl(),
    ),
  );
}

class InformacoesParaRequest implements IInformacoesParaRequests {
  final IHttpSource httpSource;

  InformacoesParaRequest({required this.httpSource});

  @override
  IHttpSource get httpClient => httpSource;

  @override
  Uri get uriBase => Uri.parse(
        'https://apollo-api-stg.coralcloud.app',
      );
}
