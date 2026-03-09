import 'package:core/injecoes.dart';
import 'package:produtos/data/remote/tamanhos_remote_datasource.dart';
import 'package:produtos/data/remote/cores_remote_datasource.dart';
import 'package:produtos/data/remote/categorias_remote_datasource.dart';
import 'package:produtos/data/remote/sub_categorias_remote_datasource.dart';
import 'package:produtos/data/remote/marcas_remote_datasource.dart';
import 'package:produtos/data/remote/referencias_remote_datasource.dart';
import 'package:produtos/data/remote/produtos_remote_datasource.dart';
import 'package:produtos/data/remote/codigo_de_barras_remote_datasource.dart';
import 'package:produtos/data/repositorios/tamanhos_repository.dart';
import 'package:produtos/data/repositorios/cores_repository.dart';
import 'package:produtos/data/repositorios/categorias_repository.dart';
import 'package:produtos/data/repositorios/sub_categorias_repository.dart';
import 'package:produtos/data/repositorios/marcas_repository.dart';
import 'package:produtos/data/repositorios/referencias_repository.dart';
import 'package:produtos/data/repositorios/produtos_repository.dart';
import 'package:produtos/data/repositorios/codigo_de_barras_repository.dart';
import 'package:produtos/domain/data/remote/i_tamanhos_remote_data_source.dart';
import 'package:produtos/domain/data/remote/i_cores_remote_data_source.dart';
import 'package:produtos/domain/data/remote/i_categorias_remote_data_source.dart';
import 'package:produtos/domain/data/remote/i_sub_categorias_remote_data_source.dart';
import 'package:produtos/domain/data/remote/i_marcas_remote_data_source.dart';
import 'package:produtos/domain/data/remote/i_referencias_remote_data_source.dart';
import 'package:produtos/domain/data/remote/i_produtos_remote_data_source.dart';
import 'package:produtos/domain/data/remote/i_codigo_de_barras_remotedatasource.dart';
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

  sl.registerFactory<ISubCategoriasRemoteDataSource>(
    () => SubCategoriasRemoteDatasource(informacoesParaRequest: sl()),
  );

  sl.registerFactory<IMarcasRemoteDataSource>(
    () => MarcasRemoteDatasource(informacoesParaRequest: sl()),
  );

  sl.registerFactory<IReferenciasRemoteDataSource>(
    () => ReferenciasRemoteDatasource(informacoesParaRequest: sl()),
  );

  sl.registerFactory<IProdutosRemoteDataSource>(
    () => ProdutosRemoteDatasource(informacoesParaRequest: sl()),
  );

  sl.registerFactory<ICodigoDeBarrasRemoteDatasource>(
    () => CodigoDeBarrasRemoteDatasource(informacoesParaRequest: sl()),
  );
}

void _repositores() {
  sl.registerFactory<ITamanhosRepository>(
    () => TamanhosRepository(tamanhosRemoteDataSource: sl()),
  );

  sl.registerFactory<ICoresRepository>(
    () => CoresRepository(coresRemoteDataSource: sl()),
  );

  sl.registerFactory<ISubCategoriasRepository>(
    () => SubCategoriasRepository(subCategoriasRemoteDataSource: sl()),
  );

  sl.registerFactory<ICategoriasRepository>(
    () => CategoriasRepository(categoriasRemoteDataSource: sl()),
  );

  sl.registerFactory<IMarcasRepository>(
    () => MarcasRepository(marcasRemoteDataSource: sl()),
  );

  sl.registerFactory<IReferenciasRepository>(
    () => ReferenciasRepository(referenciasRemoteDataSource: sl()),
  );

  sl.registerFactory<IProdutosRepository>(
    () => ProdutosRepository(produtosRemoteDataSource: sl()),
  );

  sl.registerFactory<ICodigoDeBarrasRepository>(
    () => CodigoDeBarrasRepository(codigoDeBarrasRemoteDatasource: sl()),
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

  // Sub-Categorias Use Cases
  sl.registerFactory<RecuperarSubCategorias>(
    () => RecuperarSubCategorias(subCategoriasRepository: sl()),
  );

  sl.registerFactory<CriarSubCategoria>(
    () => CriarSubCategoria(subCategoriasRepository: sl()),
  );

  sl.registerFactory<DesativarSubCategoria>(
    () => DesativarSubCategoria(subCategoriasRepository: sl()),
  );

  sl.registerFactory<RecuperarSubCategoria>(
    () => RecuperarSubCategoria(subCategoriasRepository: sl()),
  );

  sl.registerFactory<AtualizarSubCategoria>(
    () => AtualizarSubCategoria(subCategoriasRepository: sl()),
  );

  // Marcas Use Cases
  sl.registerFactory<RecuperarMarcas>(
    () => RecuperarMarcas(marcasRepository: sl()),
  );

  sl.registerFactory<CriarMarca>(() => CriarMarca(marcasRepository: sl()));

  sl.registerFactory<DesativarMarca>(
    () => DesativarMarca(marcasRepository: sl()),
  );

  sl.registerFactory<RecuperarMarca>(
    () => RecuperarMarca(marcasRepository: sl()),
  );

  sl.registerFactory<AtualizarMarca>(
    () => AtualizarMarca(marcasRepository: sl()),
  );

  // Referencias Use Cases
  sl.registerFactory<AtualizarReferencia>(
    () => AtualizarReferencia(referenciasRepository: sl()),
  );

  sl.registerFactory<CriarReferencia>(
    () => CriarReferencia(referenciasRepository: sl()),
  );

  sl.registerFactory<RecuperarReferencias>(
    () => RecuperarReferencias(referenciasRepository: sl()),
  );

  // Produtos Use Cases
  sl.registerFactory<RecuperarProdutos>(
    () => RecuperarProdutos(produtosRepository: sl()),
  );

  sl.registerFactory<CriarProduto>(
    () => CriarProduto(produtosRepository: sl()),
  );

  sl.registerFactory<AtualizarProduto>(
    () => AtualizarProduto(produtosRepository: sl()),
  );

  sl.registerFactory<ExcluirProduto>(
    () => ExcluirProduto(produtosRepository: sl()),
  );

  sl.registerFactory<CriarCodigoDeBarras>(
    () => CriarCodigoDeBarras(codigoDeBarrasRepository: sl()),
  );

  sl.registerFactory<DeletarCodigoDeBarras>(
    () => DeletarCodigoDeBarras(codigoDeBarrasRepository: sl()),
  );
}

void _presentantion() {
  sl.registerFactory<TamanhosBloc>(() => TamanhosBloc(sl(), sl()));

  sl.registerFactory<TamanhoBloc>(() => TamanhoBloc(sl(), sl(), sl()));

  sl.registerFactory<CoresBloc>(() => CoresBloc(sl(), sl()));

  sl.registerFactory<CorBloc>(() => CorBloc(sl(), sl(), sl()));

  sl.registerFactory<CategoriasBloc>(() => CategoriasBloc(sl(), sl()));

  sl.registerFactory<CategoriaBloc>(() => CategoriaBloc(sl(), sl(), sl()));

  sl.registerFactory<SubCategoriasBloc>(() => SubCategoriasBloc(sl(), sl()));

  sl.registerFactory<SubCategoriaBloc>(
    () => SubCategoriaBloc(sl(), sl(), sl()),
  );

  sl.registerFactory<MarcasBloc>(() => MarcasBloc(sl(), sl()));

  sl.registerFactory<MarcaBloc>(() => MarcaBloc(sl(), sl(), sl()));

  sl.registerFactory<ReferenciasBloc>(() => ReferenciasBloc(sl()));

  sl.registerFactory<ProdutosBloc>(() => ProdutosBloc(sl(), sl()));

  sl.registerFactory<ProdutoBloc>(() => ProdutoBloc(sl(), sl(), sl(), sl()));

  sl.registerFactory<ReferenciaCadastroBloc>(
    () => ReferenciaCadastroBloc(sl(), sl(), sl()),
  );

  sl.registerFactory<CategoriaSubCategoriaSelecaoBloc>(
    () => CategoriaSubCategoriaSelecaoBloc(sl(), sl()),
  );

  sl.registerFactory<TextoLongoEdicaoBloc>(() => TextoLongoEdicaoBloc());
}
