import 'package:core/injecoes.dart';
import 'package:produtos/data/remote/tamanhos_remote_datasource.dart';
import 'package:produtos/data/remote/cores_remote_datasource.dart';
import 'package:produtos/data/remote/categorias_remote_datasource.dart';
import 'package:produtos/data/repositorios/tamanhos_repository.dart';
import 'package:produtos/data/repositorios/cores_repository.dart';
import 'package:produtos/data/repositorios/categorias_repository.dart';
import 'package:produtos/domain/data/remote/i_tamanhos_remote_data_source.dart';
import 'package:produtos/domain/data/remote/i_cores_remote_data_source.dart';
import 'package:produtos/domain/data/remote/i_categorias_remote_data_source.dart';
import 'package:produtos/presentation.dart';
import 'package:produtos/repositorios.dart';
import 'package:produtos/use_cases.dart';

void resolverProdutosInjection() {
  _data();
  _repositores();
  _usesCases();
  _presentantion();
}

void _data() {
  sl.registerFactory<ITamanhosRemoteDataSource>(
    () => TamanhosRemoteDatasource(informacoesParaRequest: sl()),
  );

  sl.registerFactory<ICoresRemoteDataSource>(
    () => CoresRemoteDatasource(informacoesParaRequest: sl()),
  );

  sl.registerFactory<ICategoriasRemoteDataSource>(
    () => CategoriasRemoteDatasource(informacoesParaRequest: sl()),
  );
}

void _repositores() {
  sl.registerFactory<ITamanhosRepository>(
    () => TamanhosRepository(tamanhosRemoteDataSource: sl()),
  );

  sl.registerFactory<ICoresRepository>(
    () => CoresRepository(coresRemoteDataSource: sl()),
  );

  sl.registerFactory<ICategoriasRepository>(
    () => CategoriasRepository(categoriasRemoteDataSource: sl()),
  );
}

void _usesCases() {
  sl.registerFactory<RecuperarTamanhos>(
    () => RecuperarTamanhos(tamanhosRepository: sl()),
  );

  sl.registerFactory<CriarTamanho>(
    () => CriarTamanho(tamanhosRepository: sl()),
  );

  sl.registerFactory<DesativarTamanho>(
    () => DesativarTamanho(tamanhosRepository: sl()),
  );

  sl.registerFactory<RecuperarTamanho>(
    () => RecuperarTamanho(tamanhosRepository: sl()),
  );

  sl.registerFactory<AtualizarTamanho>(
    () => AtualizarTamanho(tamanhosRepository: sl()),
  );

  // Cores Use Cases
  sl.registerFactory<RecuperarCores>(
    () => RecuperarCores(coresRepository: sl()),
  );

  sl.registerFactory<CriarCor>(() => CriarCor(coresRepository: sl()));

  sl.registerFactory<DesativarCor>(() => DesativarCor(coresRepository: sl()));

  sl.registerFactory<RecuperarCor>(() => RecuperarCor(coresRepository: sl()));

  sl.registerFactory<AtualizarCor>(() => AtualizarCor(coresRepository: sl()));

  // Categorias Use Cases
  sl.registerFactory<RecuperarCategorias>(
    () => RecuperarCategorias(categoriasRepository: sl()),
  );

  sl.registerFactory<CriarCategoria>(
    () => CriarCategoria(categoriasRepository: sl()),
  );

  sl.registerFactory<DesativarCategoria>(
    () => DesativarCategoria(categoriasRepository: sl()),
  );

  sl.registerFactory<RecuperarCategoria>(
    () => RecuperarCategoria(categoriasRepository: sl()),
  );

  sl.registerFactory<AtualizarCategoria>(
    () => AtualizarCategoria(categoriasRepository: sl()),
  );
}

void _presentantion() {
  sl.registerFactory<TamanhosBloc>(() => TamanhosBloc(sl(), sl()));

  sl.registerFactory<TamanhoBloc>(() => TamanhoBloc(sl(), sl(), sl()));

  sl.registerFactory<CoresBloc>(() => CoresBloc(sl(), sl()));

  sl.registerFactory<CorBloc>(() => CorBloc(sl(), sl(), sl()));

  sl.registerFactory<CategoriasBloc>(() => CategoriasBloc(sl(), sl()));

  sl.registerFactory<CategoriaBloc>(() => CategoriaBloc(sl(), sl(), sl()));
}
