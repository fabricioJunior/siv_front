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
}
