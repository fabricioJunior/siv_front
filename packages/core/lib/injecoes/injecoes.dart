import 'package:core/http/http_implementacao/auth_http_interceptor.dart';
import 'package:core/http/i_http_source.dart';
import 'package:core/http/http_implementacao/http_source.dart';
import 'package:get_it/get_it.dart';
import 'package:http_interceptor/http_interceptor.dart';

GetIt sl = GetIt.instance;

void coreInjections() {
  sl.registerFactory<IHttpSource>(
    () => HttpSource(
      client: InterceptedClient.build(
        interceptors: [
          AuthHttpInterceptor(
            sl(),
          )
        ],
      ),
    ),
  );
}
