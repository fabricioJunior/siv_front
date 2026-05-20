import 'package:comercial/models.dart';

abstract class ICreditoDevolucaoRemoteDataSource {
  Future<List<CreditoDevolucaoMovimentacao>> buscarMovimentacoes({
    required int pessoaId,
    List<int>? empresaIds,
    DateTime? dataInicio,
    DateTime? dataFim,
  });
}
