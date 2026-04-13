import 'package:core/imagens/cache_imagem_service.dart';
import 'package:core/injecoes/api_base_url_config.dart';
import 'package:core/local_data_sourcers/database_configs/i_isar_database_instance.dart';
import 'package:core/local_data_sourcers/database_configs/isar_database_instance.dart';
import 'package:core/paginacao/i_paginacao_data_source.dart';
import 'package:core/paginacao/paginacao.dart';
import 'package:core/paginacao/paginacao_data_source.dart';
import 'package:core/produtos_compartilhados.dart';
import 'package:core/produtos_compartilhados/local/dtos/lista_de_produtos_compartilhada_dto.dart';
import 'package:core/produtos_compartilhados/local/dtos/produto_compartilhado_dto.dart';
import 'package:core/produtos_compartilhados/local/i_lista_de_produtos_compartilhada_local_data_source.dart';
import 'package:core/produtos_compartilhados/local/i_produtos_compartilhados_local_data_source.dart';
import 'package:core/produtos_compartilhados/local/lista_de_produtos_compartilhada_local_data_source.dart';
import 'package:core/produtos_compartilhados/local/produtos_compartilhados_local_data_source.dart';
import 'package:core/produtos_compartilhados/repositories/lista_de_produtos_compartilhada_repository.dart';
import 'package:core/remote_data_sourcers.dart';
import 'package:core/cep.dart';
import 'package:get_it/get_it.dart';
import 'package:isar_community/isar.dart';

import '../produtos_compartilhados/repositories/i_lista_de_produtos_compartilhada_repository.dart';

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

  sl.registerLazySingleton<IListaDeProdutosCompartilhadaLocalDataSource>(
    () => ListaDeProdutosCompartilhadaLocalDataSource(getIsar: _getIsar),
  );

  sl.registerLazySingleton<IProdutosCompartilhadosLocalDataSource>(
    () => ProdutosCompartilhadosLocalDataSource(getIsar: _getIsar),
  );

  sl.registerLazySingleton<IListaDeProdutosCompartilhadaRepository>(
    () => ListaDeProdutosCompartilhadaRepository(
      listasLocalDataSource: sl(),
      produtosLocalDataSource: sl(),
    ),
  );

  sl.registerFactory<SalvarListaDeProdutosCompartilhada>(
    () => SalvarListaDeProdutosCompartilhada(repository: sl()),
  );
  sl.registerFactory<RecuperarListaDeProdutosCompartilhada>(
    () => RecuperarListaDeProdutosCompartilhada(repository: sl()),
  );

  sl.registerFactory<RemoverListaDeProdutosCompartilhada>(
    () => RemoverListaDeProdutosCompartilhada(repository: sl()),
  );

  sl.registerFactory<RemoverProdutoCompartilhado>(
    () => RemoverProdutoCompartilhado(repository: sl()),
  );

  sl.registerFactory<AtualizarListaCompartilhada>(
    () => AtualizarListaCompartilhada(repository: sl()),
  );

  sl.registerFactory<IPaginacaoDataSource>(
    () => PaginacaoDataSource(
      getIsar: _getIsar,
    ),
  );

  sl.registerFactory<IIsarDatabaseInstance>(() => IsarDatabaseInstance());
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
  List<CollectionSchema<dynamic>> schemas = [
    PaginacaoSchema,
    ProdutoCompartilhadoDtoSchema,
    ListaDeProdutosCompartilhadaDtoSchema,
  ];

  return sl<IIsarDatabaseInstance>().getIsar(
    schemas: schemas,
    isSyncData: isSyncData ?? false,
    isCommonData: true,
    moduleName: 'core',
  );
}
