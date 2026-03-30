import 'dart:io';

import 'package:core/imagens/cache_imagem_service.dart';
import 'package:core/injecoes/api_base_url_config.dart';
import 'package:core/local_data_sourcers/database_configs/i_isar_database_instance.dart';
import 'package:core/local_data_sourcers/database_configs/isar_database_instance.dart';
import 'package:core/local_data_sourcers/isar/isar_configuracoes.dart';
import 'package:core/paginacao/i_paginacao_data_source.dart';
import 'package:core/paginacao/paginacao.dart';
import 'package:core/paginacao/paginacao_data_source.dart';
import 'package:core/remote_data_sourcers.dart';
import 'package:core/cep.dart';
import 'package:get_it/get_it.dart';
import 'package:isar_community/isar.dart';

GetIt sl = GetIt.instance;

void coreInjections() {
  sl.registerFactory<IInformacoesParaRequests>(
    () => InformacoesParaRequest(
      httpSource: sl(),
      apiBaseUrlConfig: sl(),
    ),
  );

  sl.registerLazySingleton<ApiBaseUrlConfig>(() => ApiBaseUrlConfig());

  sl.registerLazySingleton<CepService>(() => CepService());

  sl.registerFactory<ICacheImagemService>(() => CacheImagemService());

  sl.registerFactory<IPaginacaoDataSource>(
    () => PaginacaoDataSource(
      getIsar: _getIsar,
    ),
  );

  sl.registerLazySingleton<IIsarDatabaseInstance>(() => IsarDatabaseInstance());
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

Future<Isar> _getIsar({bool? isSyncData = false}) async {
  var instanceName = '${isSyncData ?? false ? 'sync_' : ''} core';

  var directory = Directory('${isarDirectory!.path}/$instanceName');

  if (!directory.existsSync()) {
    directory.createSync();
  }
  List<CollectionSchema<dynamic>> schemas = [
    PaginacaoSchema,
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
