import 'package:core/injecoes.dart';
import 'package:core/precos_portas.dart';
import 'package:precos/data/local/precos_local_data_sources.dart';
import 'package:precos/domain/adapters/porta_obter_preco_da_referencia_impl.dart';
import 'package:precos/data/remote/precos_de_referencias_remote_data_source.dart';
import 'package:precos/data/remote/tabela_de_preco_remote_data_source.dart';
import 'package:precos/data/repositorios/precos_de_referencias_repository.dart';
import 'package:precos/data/repositorios/tabelas_de_preco_repository.dart';
import 'package:precos/data/remote/importacao_tabela_de_preco_remote_data_source.dart';
import 'package:precos/data/repositorios/importacao_tabela_de_preco_repository.dart';
import 'package:precos/domain/data/remote/i_importacao_tabela_de_preco_remote_data_source.dart';
import 'package:precos/domain/data/remote/i_precos_de_referencias_remote_data_source.dart';
import 'package:precos/domain/data/remote/i_tabelas_de_preco_remote_data_source.dart';
import 'package:precos/presentation.dart';
import 'package:precos/repositorios.dart';
import 'package:precos/use_cases.dart';

void resolverPrecosInjection() {
  _dataSources();
  _repositores();
  _usesCases();
  _presentantion();
}

void _dataSources() {
  sl.registerFactory<ITabelasDePrecoRemoteDataSource>(
    () => TabelaDePrecoRemoteDataSource(informacoesParaRequest: sl()),
  );
  sl.registerFactory<IPrecosDeReferenciasRemoteDataSource>(
    () => PrecosDeReferenciasRemoteDataSource(informacoesParaRequest: sl()),
  );

  registerPrecosLocalDataSources();

  sl.registerFactory<IImportacaoTabelaDePrecoRemoteDataSource>(
    () => ImportacaoTabelaDePrecoRemoteDataSource(informacoesParaRequest: sl()),
  );
}

void _repositores() {
  sl.registerFactory<ITabelasDePrecoRepository>(
    () => TabelasDePrecoRepository(
      tabelasDePrecoRemoteDataSource: sl(),
      tabelasDePrecoLocalDataSource: sl(),
      paginacaoDataSource: sl(),
    ),
  );
  sl.registerFactory<IPrecosDeReferenciasRepository>(
    () => PrecosDeReferenciasRepository(
      precosDeReferenciasRemoteDataSource: sl(),
      paginacaoDataSource: sl(),
      tabelasDePrecoLocalDataSource: sl(),
      precosDeReferenciasLocalDataSource: sl(),
    ),
  );

  sl.registerFactory<IImportacaoTabelaDePrecoRepository>(
    () => ImportacaoTabelaDePrecoRepository(remoteDataSource: sl()),
  );
}

void _usesCases() {
  sl.registerFactory<RecuperarTabelasDePreco>(
    () => RecuperarTabelasDePreco(tabelasDePrecoRepository: sl()),
  );
  sl.registerFactory<RecuperarTabelaDePreco>(
    () => RecuperarTabelaDePreco(tabelasDePrecoRepository: sl()),
  );
  sl.registerFactory<CriarTabelaDePreco>(
    () => CriarTabelaDePreco(tabelasDePrecoRepository: sl()),
  );
  sl.registerFactory<AtualizarTabelaDePreco>(
    () => AtualizarTabelaDePreco(tabelasDePrecoRepository: sl()),
  );
  sl.registerFactory<DesativarTabelaDePreco>(
    () => DesativarTabelaDePreco(tabelasDePrecoRepository: sl()),
  );
  sl.registerFactory<RecuperarPrecosDasReferencias>(
    () => RecuperarPrecosDasReferencias(precosDeReferenciasRepository: sl()),
  );
  sl.registerFactory<AtualizarPrecoDaReferencia>(
    () => AtualizarPrecoDaReferencia(precosDeReferenciasRepository: sl()),
  );
  sl.registerFactory<ObterPrecoDaReferencia>(
    () => ObterPrecoDaReferencia(precosDeReferenciasRepository: sl()),
  );
  sl.registerFactory<RemoverPrecoDaReferencia>(
    () => RemoverPrecoDaReferencia(precosDeReferenciasRepository: sl()),
  );
  sl.registerFactory<SincronziarTabelasDePreco>(
    () => SincronziarTabelasDePreco(tabelasDePrecoRepository: sl()),
  );
  sl.registerFactory<SincronizarPrecos>(
    () => SincronizarPrecos(precosDeReferenciasRepository: sl()),
  );

  sl.registerFactory<BaixarTemplateImportacaoTabelaDePreco>(
    () => BaixarTemplateImportacaoTabelaDePreco(repository: sl()),
  );
  sl.registerFactory<ImportarTabelaDePrecoCsv>(
    () => ImportarTabelaDePrecoCsv(repository: sl()),
  );
  sl.registerFactory<ConsultarImportacaoTabelaDePreco>(
    () => ConsultarImportacaoTabelaDePreco(repository: sl()),
  );

  sl.registerFactory<PortaObterPrecoDaReferencia>(
    () => PortaObterPrecoDaReferenciaImpl(sl()),
  );
}

void _presentantion() {
  sl.registerFactory<TabelasDePrecoBloc>(() => TabelasDePrecoBloc(sl(), sl()));
  sl.registerFactory<TabelaDePrecoBloc>(
    () => TabelaDePrecoBloc(sl(), sl(), sl()),
  );
  sl.registerFactory<EditarPrecoDaReferenciaBloc>(
    () => EditarPrecoDaReferenciaBloc(sl(), sl()),
  );
  sl.registerFactory<PrecosDaTabelaBloc>(() => PrecosDaTabelaBloc(sl(), sl()));
  sl.registerFactory<ImportarTabelaDePrecoCsvBloc>(
    () => ImportarTabelaDePrecoCsvBloc(sl(), sl(), sl(), sl()),
  );
}

