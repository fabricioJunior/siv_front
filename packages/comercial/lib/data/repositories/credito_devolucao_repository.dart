import 'package:comercial/data.dart';
import 'package:comercial/models.dart';

class CreditoDevolucaoRepository implements ICreditoDevolucaoRepository {
  final ICreditoDevolucaoRemoteDataSource remoteDataSource;
  final ISaldoTotalCreditoDevolucaoRemoteDataSource saldoTotalRemoteDataSource;

  CreditoDevolucaoRepository({
    required this.remoteDataSource,
    required this.saldoTotalRemoteDataSource,
  });

  @override
  Future<double> buscarSaldo({required int pessoaId}) {
    return saldoTotalRemoteDataSource.buscarSaldo(pessoaId: pessoaId);
  }

  @override
  Future<List<CreditoDevolucaoMovimentacao>> buscarMovimentacoes({
    required int pessoaId,
    List<int>? empresaIds,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) {
    return remoteDataSource.buscarMovimentacoes(
      pessoaId: pessoaId,
      empresaIds: empresaIds,
      dataInicio: dataInicio,
      dataFim: dataFim,
    );
  }

  @override
  Future<List<CreditoTransferivel>> buscarTransferiveis({
    required int pessoaId,
  }) {
    return remoteDataSource.buscarTransferiveis(pessoaId: pessoaId);
  }

  @override
  Future<ResultadoTransferenciaCredito> transferir({
    required int pessoaId,
    required List<int> romaneioIds,
  }) {
    return remoteDataSource.transferir(
      pessoaId: pessoaId,
      romaneioIds: romaneioIds,
    );
  }

  @override
  Future<List<CreditoDevolucao>> buscarCreditos({
    required int pessoaId,
    required String situacao,
  }) {
    return remoteDataSource.buscarCreditos(
      pessoaId: pessoaId,
      situacao: situacao,
    );
  }

  @override
  Future<ResumoCreditoDevolucao> buscarResumo({required int pessoaId}) {
    return remoteDataSource.buscarResumo(pessoaId: pessoaId);
  }

  @override
  Future<ResultadoAcaoCredito> adicionar({
    required int pessoaId,
    required double valor,
    required String motivo,
    required String observacao,
    DateTime? validade,
    int? empresaId,
  }) {
    return remoteDataSource.adicionar(
      pessoaId: pessoaId,
      valor: valor,
      motivo: motivo,
      observacao: observacao,
      validade: validade,
      empresaId: empresaId,
    );
  }

  @override
  Future<ResultadoAcaoCredito> remover({
    required int pessoaId,
    required int creditoId,
    double? valor,
    required String motivo,
    String? observacao,
  }) {
    return remoteDataSource.remover(
      pessoaId: pessoaId,
      creditoId: creditoId,
      valor: valor,
      motivo: motivo,
      observacao: observacao,
    );
  }

  @override
  Future<ResultadoAcaoCredito> expirar({
    required int pessoaId,
    required int creditoId,
    String? motivo,
  }) {
    return remoteDataSource.expirar(
      pessoaId: pessoaId,
      creditoId: creditoId,
      motivo: motivo,
    );
  }
}
