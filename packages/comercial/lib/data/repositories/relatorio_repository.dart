import 'package:comercial/domain/data/remote/i_relatorio_remote_data_source.dart';
import 'package:comercial/domain/data/repositories/i_relatorio_repository.dart';
import 'package:comercial/domain/models/relatorios.dart';

class RelatorioRepository implements IRelatorioRepository {
  final IRelatorioRemoteDataSource _remoteDataSource;

  RelatorioRepository({required IRelatorioRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<RelatorioFaturamento> faturamento({
    required List<int> empresaIds,
    required String dataInicial,
    required String dataFinal,
  }) =>
      _remoteDataSource.faturamento(
        empresaIds: empresaIds,
        dataInicial: dataInicial,
        dataFinal: dataFinal,
      );

  @override
  Future<RelatorioFaturamentoComparativo> faturamentoComparativo({
    required List<int> empresaIds,
    required String dataInicial,
    required String dataFinal,
    required String agruparPor,
  }) =>
      _remoteDataSource.faturamentoComparativo(
        empresaIds: empresaIds,
        dataInicial: dataInicial,
        dataFinal: dataFinal,
        agruparPor: agruparPor,
      );

  @override
  Future<RelatorioCurvaAbc> curvaAbc({
    required List<int> empresaIds,
    required String dataInicial,
    required String dataFinal,
    String? busca,
    int page = 1,
    int limit = 100,
    String agruparPor = 'produto',
    List<int>? referenciaIds,
    List<int>? categoriaIds,
  }) =>
      _remoteDataSource.curvaAbc(
        empresaIds: empresaIds,
        dataInicial: dataInicial,
        dataFinal: dataFinal,
        busca: busca,
        page: page,
        limit: limit,
        agruparPor: agruparPor,
        referenciaIds: referenciaIds,
        categoriaIds: categoriaIds,
      );

  @override
  Future<RelatorioClientesAtivos> clientesAtivos({
    required List<int> empresaIds,
    required int dias,
    String? dataReferencia,
    int page = 1,
    int limit = 100,
  }) =>
      _remoteDataSource.clientesAtivos(
        empresaIds: empresaIds,
        dias: dias,
        dataReferencia: dataReferencia,
        page: page,
        limit: limit,
      );

  @override
  Future<List<RelatorioVendasPorFuncionarioItem>> vendasPorFuncionario({
    required List<int> empresaIds,
    required List<int> funcionarioIds,
    required String dataInicial,
    required String dataFinal,
  }) =>
      _remoteDataSource.vendasPorFuncionario(
        empresaIds: empresaIds,
        funcionarioIds: funcionarioIds,
        dataInicial: dataInicial,
        dataFinal: dataFinal,
      );
}
