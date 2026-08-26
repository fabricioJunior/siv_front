import 'package:core/imagens/cache_imagem_service.dart';
import 'package:core/impressoras/printers/i_printers_service.dart';
import 'package:core/impressoras/printers/impressora_preferida_local_data_source.dart';
import 'package:core/impressoras/printers/printers_service.dart';
import 'package:core/impressoras/printers/repositories/i_impressora_preferida_repository.dart';
import 'package:core/impressoras/printers/repositories/impressora_preferida_repository.dart';
import 'package:core/impressoras/printers/use_cases/obter_impressora_preferida.dart';
import 'package:core/impressoras/printers/use_cases/salvar_impressora_preferida.dart';
import 'package:core/injecoes/api_base_url_config.dart';
import 'package:core/injecoes/core_local_storage.dart';
import 'package:core/produtos_compartilhados.dart';
import 'package:core/produtos_compartilhados/repositories/lista_de_produtos_compartilhada_repository.dart';
import 'package:core/remote_data_sourcers.dart';
import 'package:core/arquivos.dart';
import 'package:core/cep.dart';
import 'package:core/links.dart';
import 'package:get_it/get_it.dart';

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

  sl.registerLazySingleton<IPrintersService>(() => PrintersService());

  sl.registerLazySingleton<IImpressoraPreferidaLocalDataSource>(
    () => ImpressoraPreferidaLocalDataSource(),
  );

  sl.registerLazySingleton<IImpressoraPreferidaRepository>(
    () => ImpressoraPreferidaRepository(localDataSource: sl()),
  );

  sl.registerFactory<ObterImpressoraPreferida>(
    () => ObterImpressoraPreferida(repository: sl()),
  );

  sl.registerFactory<SalvarImpressoraPreferida>(
    () => SalvarImpressoraPreferida(repository: sl()),
  );

  sl.registerLazySingleton<CepService>(() => CepService());

  sl.registerLazySingleton<ArquivoService>(() => ArquivoService());

  sl.registerLazySingleton<LinkService>(() => LinkService());

  sl.registerFactory<ICacheImagemService>(() => CacheImagemService());

  registerCoreLocalStorage();

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

  sl.registerFactory<RemoverProdutosDaListaCompartilhada>(
    () => RemoverProdutosDaListaCompartilhada(repository: sl()),
  );
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

