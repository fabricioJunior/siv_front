import 'package:financeiro/domain/data/remote/i_recibo_fechamento_caixa_remote_data_source.dart';
import 'package:financeiro/domain/data/repositories/i_recibo_fechamento_caixa_repository.dart';
import 'package:financeiro/domain/models/recibo_fechamento_caixa.dart';

class ReciboFechamentoCaixaRepository
    implements IReciboFechamentoCaixaRepository {
  final IReciboFechamentoCaixaRemoteDataSource remoteDataSource;

  ReciboFechamentoCaixaRepository({required this.remoteDataSource});

  @override
  Future<ReciboFechamentoCaixa> recuperarReciboFechamento({
    required int caixaId,
  }) {
    return remoteDataSource.recuperarReciboFechamento(caixaId: caixaId);
  }
}
