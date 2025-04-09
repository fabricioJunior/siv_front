import 'dart:io';

import 'package:autenticacao/autenticao_injecoes.dart';
import 'package:autenticacao/data.dart';
import 'package:autenticacao/data/remote/auth_http_interceptor.dart';
import 'package:autenticacao/domain/data/data_sourcers/remote/i_usuarios_remote_data_source.dart';
import 'package:core/injecoes.dart';
import 'package:core/isar_anotacoes.dart';
import 'package:core/remote_data_sourcers.dart';
import 'package:empresas/empresas_injections.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:siv_front/bloc/app_bloc.dart';
import 'package:siv_front/infra/local_data_sourcers/dtos/usuario_dto.dart';
import 'package:siv_front/infra/local_data_sourcers/usuario_da_sessa_local_data_source.dart';
import 'package:siv_front/infra/remote_data_sourcers/usuario_da_sessao_remote_data_source.dart';

import 'infra/remote_data_sourcers/usuarios_remote_datasource.dart';

void resolverDependenciasApp() {
  _localDataSource();
  _remoteDataSources();
  coreInjections();
  resolverDependenciasAutenticacao();
  resolverDependenciasEmpresas();
  _presentation();
  sl.registerLazySingleton<IHttpSource>(
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

void _remoteDataSources() {
  sl.registerFactory<IUsuarioDaSessaoRemoteDataSource>(
    () => UsuarioDaSessaoRemoteDataSource(
      informacoesParaRequest: InformacoesParaRequest(
        httpSource: sl(),
      ),
    ),
  );
  sl.registerFactory<IUsuariosRemoteDataSource>(
    () => UsuariosRemoteDatasource(
      informacoesParaRequest: sl(),
    ),
  );
}

void _localDataSource() {
  sl.registerFactory<IUsuarioDaSessaoLocalDataSource>(
      () => UsuarioDaSessaLocalDataSource(getIsar: _getIsar));
}

void _presentation() {
  sl.registerLazySingleton(() => AppBloc(
        sl(),
        sl(),
        sl(),
        sl(),
      )..add(AppIniciou()));
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

Future<Isar> _getIsar({bool? isSyncData = false}) async {
  var instanceName = '${isSyncData ?? false ? 'sync_' : ''} root';

  var directory = Directory('${isarDirectory!.path}/$instanceName');

  if (!directory.existsSync()) {
    directory.createSync();
  }
  List<CollectionSchema<dynamic>> schemas = [
    UsuarioDtoSchema,
  ];

  Isar isar = Isar.getInstance(instanceName) ??
      Isar.openSync(
        schemas,
        directory: directory.path,
        name: instanceName,
        inspector: false,
      );
  return isar;
}
