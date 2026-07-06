import 'package:core/injecoes.dart';
import 'package:core/isar_anotacoes.dart';
import 'package:core/local_data_sourcers/database_configs/i_isar_database_instance.dart';
import 'package:estoque/data/remote/estoque_saldo_remote_data_source.dart';
import 'package:estoque/data/remote/balanco_remote_data_source.dart';
import 'package:estoque/data/repositorios/estoque_repository.dart';
import 'package:estoque/data/repositories/balanco_repository.dart';
import 'package:estoque/domain/data/datasourcers/i_produtos_estoque_local_datasource.dart';
import 'package:estoque/domain/data/remote/i_estoque_saldo_remote_data_source.dart';
import 'package:estoque/domain/data/remote/i_balanco_remote_data_source.dart';
import 'package:estoque/domain/data/repositorios/i_estoque_repository.dart';
import 'package:estoque/domain/repositories/i_balanco_repository.dart';
import 'package:estoque/presentation.dart';
import 'package:estoque/use_cases.dart';

import 'data/local/dtos/produto_estoque_dto.dart';
import 'data/local/produtos_estoque_local_datasource.dart';

void resolverEstoqueInjection() {
  _dataSources();
  _repositorios();
  _useCases();
  _presentation();
}

void _dataSources() {
  sl.registerFactory<IEstoqueSaldoRemoteDataSource>(
    () => EstoqueSaldoRemoteDataSource(informacoesParaRequest: sl()),
  );
  sl.registerFactory<IProdutoEstoqueLocalDataSource>(
    () => ProdutosEstoqueLocalDatasource(getIsar: _getIsar),
  );
  sl.registerFactory<IBalancoRemoteDataSource>(
    () => BalancoRemoteDataSource(informacoesParaRequest: sl()),
  );
}

void _repositorios() {
  sl.registerFactory<IEstoqueRepository>(
    () => EstoqueRepository(
      estoqueSaldoRemoteDataSource: sl(),
      paginacaoDataSource: sl(),
      produtosEstoqueLocalDataSource: sl(),
    ),
  );
  sl.registerFactory<IBalancoRepository>(
    () => BalancoRepository(remoteDataSource: sl()),
  );
}

void _useCases() {
  sl.registerFactory<RecuperarSaldoDoEstoque>(
    () => RecuperarSaldoDoEstoque(estoqueRepository: sl()),
  );

  sl.registerFactory<SincronizarEstoque>(
    () => SincronizarEstoque(estoqueRepository: sl()),
  );

  // Balanço Use Cases
  sl.registerFactory<CriarBalancoUseCase>(
    () => CriarBalancoUseCase(repository: sl()),
  );
  sl.registerFactory<ListarBalancosUseCase>(
    () => ListarBalancosUseCase(repository: sl()),
  );
  sl.registerFactory<ObterBalancoUseCase>(
    () => ObterBalancoUseCase(repository: sl()),
  );
  sl.registerFactory<AtualizarBalancoUseCase>(
    () => AtualizarBalancoUseCase(repository: sl()),
  );
  sl.registerFactory<EncerrarBalancoUseCase>(
    () => EncerrarBalancoUseCase(repository: sl()),
  );
  sl.registerFactory<CancelarBalancoUseCase>(
    () => CancelarBalancoUseCase(repository: sl()),
  );
  sl.registerFactory<ObterResumoBalancoUseCase>(
    () => ObterResumoBalancoUseCase(repository: sl()),
  );
  sl.registerFactory<AdicionarItemAoBalancoUseCase>(
    () => AdicionarItemAoBalancoUseCase(repository: sl()),
  );
  sl.registerFactory<AdicionarMultiplosItensAoBalancoUseCase>(
    () => AdicionarMultiplosItensAoBalancoUseCase(repository: sl()),
  );
  sl.registerFactory<ListarItensDoBalancoUseCase>(
    () => ListarItensDoBalancoUseCase(repository: sl()),
  );
  sl.registerFactory<RemoverItemDoBalancoUseCase>(
    () => RemoverItemDoBalancoUseCase(repository: sl()),
  );
  sl.registerFactory<CalcularItensDoBalancoUseCase>(
    () => CalcularItensDoBalancoUseCase(repository: sl()),
  );
  sl.registerFactory<CriarLoteBalancoUseCase>(
    () => CriarLoteBalancoUseCase(repository: sl()),
  );
  sl.registerFactory<ListarLotesBalancoUseCase>(
    () => ListarLotesBalancoUseCase(repository: sl()),
  );
  sl.registerFactory<AtualizarLoteBalancoUseCase>(
    () => AtualizarLoteBalancoUseCase(repository: sl()),
  );
  sl.registerFactory<CancelarLoteBalancoUseCase>(
    () => CancelarLoteBalancoUseCase(repository: sl()),
  );
  sl.registerFactory<AdicionarItemAoLoteBalancoUseCase>(
    () => AdicionarItemAoLoteBalancoUseCase(repository: sl()),
  );
  sl.registerFactory<AdicionarMultiplosItensAoLoteBalancoUseCase>(
    () => AdicionarMultiplosItensAoLoteBalancoUseCase(repository: sl()),
  );
  sl.registerFactory<ListarItensDoLoteBalancoUseCase>(
    () => ListarItensDoLoteBalancoUseCase(repository: sl()),
  );
  sl.registerFactory<RemoverItemDoLoteBalancoUseCase>(
    () => RemoverItemDoLoteBalancoUseCase(repository: sl()),
  );
}

void _presentation() {
  sl.registerFactory<EstoqueSaldoBloc>(() => EstoqueSaldoBloc(sl()));
  sl.registerFactory<EntradaManualDeProdutosBloc>(
    () => EntradaManualDeProdutosBloc(sl(), sl(), sl()),
  );
  sl.registerFactory<BalancoBloc>(
    () => BalancoBloc(
      criarBalanco: sl(),
      listarBalancos: sl(),
      obterBalanco: sl(),
      atualizarBalanco: sl(),
      encerrarBalanco: sl(),
      cancelarBalanco: sl(),
      obterResumo: sl(),
      adicionarItem: sl(),
      adicionarMultiplosItens: sl(),
      listarItensDoBalanco: sl(),
      removerItemDoBalanco: sl(),
    ),
  );
  sl.registerFactory<BalancoItensBloc>(
    () => BalancoItensBloc(
      listarItensDoBalanco: sl(),
      removerItemDoBalanco: sl(),
      calcularItensDoBalanco: sl(),
    ),
  );
  sl.registerFactory<LotesBloc>(
    () => LotesBloc(listarLotes: sl(), cancelarLote: sl()),
  );
  sl.registerFactory<LoteBloc>(
    () => LoteBloc(
      criarLote: sl(),
      atualizarLote: sl(),
      cancelarLote: sl(),
      listarLotes: sl(),
      adicionarMultiplosItens: sl(),
      listarItens: sl(),
      removerItem: sl(),
    ),
  );
}

Future<Isar> _getIsar({bool? isSyncData}) async {
  var schemas = [ProdutoEstoqueDtoSchema];
  return sl<IIsarDatabaseInstance>().getIsar(
    schemas: schemas,
    isCommonData: true,
    isSyncData: isSyncData ?? false,
    moduleName: 'estoque',
    showInspection: true,
  );
}
