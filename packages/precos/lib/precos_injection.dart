import 'package:core/injecoes.dart';
import 'package:core/isar_anotacoes.dart';
import 'package:core/local_data_sourcers/database_configs/i_isar_database_instance.dart';
import 'package:precos/data/local/dtos/preco_da_referencia_dto.dart';
import 'package:precos/data/local/dtos/tabela_de_preco_dto.dart';
import 'package:precos/data/local/precos_de_referencias_local_data_source.dart';
import 'package:precos/data/local/tabelas_de_preco_local_data_source.dart';
import 'package:precos/data/remote/precos_de_referencias_remote_data_source.dart';
import 'package:precos/data/remote/tabela_de_preco_remote_data_source.dart';
import 'package:precos/data/repositorios/precos_de_referencias_repository.dart';
import 'package:precos/data/repositorios/tabelas_de_preco_repository.dart';
import 'package:precos/domain/data/local/i_precos_de_referencias_local_data_source.dart';
import 'package:precos/domain/data/local/i_tabelas_de_preco_local_data_source.dart';
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

  sl.registerFactory<ITabelasDePrecoLocalDataSource>(
    () => TabelasDePrecoLocalDataSource(getIsar: _getIsar),
  );
  sl.registerFactory<IPrecosDeReferenciasLocalDataSource>(
    () => PrecosDeReferenciasLocalDataSource(getIsar: _getIsar),
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
  sl.registerFactory<RemoverPrecoDaReferencia>(
    () => RemoverPrecoDaReferencia(precosDeReferenciasRepository: sl()),
  );
  sl.registerFactory<SincronziarTabelasDePreco>(
    () => SincronziarTabelasDePreco(tabelasDePrecoRepository: sl()),
  );
  sl.registerFactory<SincronizarPrecos>(
    () => SincronizarPrecos(precosDeReferenciasRepository: sl()),
  );
}

void _presentantion() {
  sl.registerFactory<TabelasDePrecoBloc>(() => TabelasDePrecoBloc(sl(), sl()));
  sl.registerFactory<TabelaDePrecoBloc>(
    () => TabelaDePrecoBloc(sl(), sl(), sl()),
  );
  sl.registerFactory<EditarPrecoDaReferenciaBloc>(
    () => EditarPrecoDaReferenciaBloc(sl()),
  );
  sl.registerFactory<PrecosDaTabelaBloc>(() => PrecosDaTabelaBloc(sl(), sl()));
}

Future<Isar> _getIsar({bool? isSyncData = false}) async {
  List<CollectionSchema<dynamic>> schemas = [
    TabelaDePrecoDtoSchema,
    PrecoDaReferenciaDtoSchema,
  ];

  return sl<IIsarDatabaseInstance>().getIsar(
    schemas: schemas,
    isCommonData: true,
    isSyncData: isSyncData ?? false,
    moduleName: 'precos',
  );
}
