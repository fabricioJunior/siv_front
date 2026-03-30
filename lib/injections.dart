import 'package:autenticacao/autenticao_injecoes.dart' as auth;
import 'package:autenticacao/data.dart';
import 'package:autenticacao/data/remote/auth_http_interceptor.dart';
import 'package:autenticacao/domain/data/data_sourcers/remote/i_empresas_remote_data_source.dart'
    as auth show IEmpresasRemoteDataSource;
import 'package:autenticacao/domain/data/data_sourcers/remote/i_usuarios_remote_data_source.dart';
import 'package:core/injecoes.dart';
import 'package:core/isar_anotacoes.dart';
import 'package:core/local_data_sourcers/database_configs/i_isar_database_instance.dart';
import 'package:core/permissoes/i_permissoes_controller.dart';
import 'package:core/remote_data_sourcers.dart';
import 'package:estoque/estoque_injections.dart';
import 'package:firebase/firebase_injecoes.dart' as firebase;

import 'package:empresas/empresas_injections.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:pessoas/pessoas_injections.dart';
import 'package:pagamentos/pagamentos_injections.dart';
import 'package:precos/precos_injection.dart';
import 'package:produtos/produtos_injection.dart';
import 'package:sistema/sistema_injections.dart';
import 'package:siv_front/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:siv_front/data/infra/local_data_sourcers/dtos/empresa_dto.dart';
import 'package:siv_front/data/infra/local_data_sourcers/dtos/licenciado_dto.dart';
import 'package:siv_front/data/infra/local_data_sourcers/dtos/usuario_dto.dart';
import 'package:siv_front/data/infra/local_data_sourcers/empresa_da_sessao_local_data_source.dart';
import 'package:siv_front/data/infra/local_data_sourcers/licenciado_da_sessao_local_data_source.dart';
import 'package:siv_front/data/infra/local_data_sourcers/usuario_da_sessao_local_data_source.dart';
import 'package:siv_front/data/infra/remote_data_sourcers/empresas_remote_data_source.dart';
import 'package:siv_front/data/infra/remote_data_sourcers/usuario_da_sessao_remote_data_source.dart';
import 'package:siv_front/domain/controllers/permissoes_controller.dart';

import 'data/infra/remote_data_sourcers/usuarios_remote_datasource.dart';

Future<void> resolverDependenciasApp() async {
  await firebase.resolverDependenciasFirebase();

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

  _localDataSource();
  _remoteDataSources();
  coreInjections();
  auth.resolverDependenciasAutenticacao();
  resolverDependenciasEmpresas();
  resolverPessoasInjections();
  resolverProdutosInjection();
  resolverSistemaInjections();
  resolverPagamentosInjections();
  resolverPrecosInjection();
  resolverEstoqueInjection();
  _presentation();
  sl.registerSingleton<IPermissoesController>(Permissoes(appBloc: sl()));
}

void _remoteDataSources() {
  sl.registerFactory<IUsuarioDaSessaoRemoteDataSource>(
    () => UsuarioDaSessaoRemoteDataSource(
      informacoesParaRequest: InformacoesParaRequest(
        httpSource: sl(),
        apiBaseUrlConfig: sl(),
      ),
    ),
  );
  sl.registerFactory<IUsuariosRemoteDataSource>(
    () => UsuariosRemoteDatasource(
      informacoesParaRequest: sl(),
    ),
  );
  sl.registerFactory<auth.IEmpresasRemoteDataSource>(
    () => EmpresasRemoteDataSource(
      informacoesParaRequest: sl(),
    ),
  );
}

void _localDataSource() {
  sl.registerFactory<IUsuarioDaSessaoLocalDataSource>(
      () => UsuarioDaSessaoLocalDataSource(getIsar: _getIsar));

  sl.registerFactory<IEmpresaDaSessaoLocalDataSource>(
    () => EmpresaDaSessaoLocalDataSource(
      getIsar: _getIsar,
    ),
  );
  sl.registerFactory<ILicenciadoDaSessaoLocalDataSource>(
    () => LicenciadoDaSessaoLocalDataSource(
      getIsar: _getIsar,
    ),
  );
}

void _presentation() {
  sl.registerLazySingleton(() => AppBloc(
        sl(),
        sl(),
        sl(),
        sl(),
        sl(),
        sl(),
        sl(),
        sl(),
        sl(),
      )..add(AppIniciou()));
}

class InformacoesParaRequest implements IInformacoesParaRequests {
  final IHttpSource httpSource;
  final ApiBaseUrlConfig apiBaseUrlConfig;

  InformacoesParaRequest({
    required this.httpSource,
    required this.apiBaseUrlConfig,
  });

  @override
  IHttpSource get httpClient => httpSource;

  @override
  Uri get uriBase => Uri.parse(
        apiBaseUrlConfig.urlBase,
      );
}

Future<Isar> _getIsar({bool? isSyncData = false}) async {
  List<CollectionSchema<dynamic>> schemas = [
    UsuarioDtoSchema,
    EmpresaDtoSchema,
    LicenciadoDtoSchema,
  ];

  return sl<IIsarDatabaseInstance>().getIsar(
    schemas: schemas,
    isCommonData: true,
    isSyncData: isSyncData ?? false,
  );
}
