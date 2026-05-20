import 'package:comercial/models.dart';

abstract class ICreditoDevolucaoRepository {
  Future<double> buscarSaldo({required int pessoaId});

  Future<List<CreditoDevolucaoMovimentacao>> buscarMovimentacoes({
    required int pessoaId,
    List<int>? empresaIds,
    DateTime? dataInicio,
    DateTime? dataFim,
  });
}
