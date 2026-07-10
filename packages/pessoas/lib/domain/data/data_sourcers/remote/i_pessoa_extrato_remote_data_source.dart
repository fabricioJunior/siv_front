import 'package:pessoas/domain/models/pessoa_extrato_movimentacao.dart';

abstract class IPessoaExtratoRemoteDataSource {
  Future<List<PessoaExtratoMovimentacao>> buscarExtrato({
    required int pessoaId,
    List<int>? empresaIds,
    DateTime? dataInicio,
    DateTime? dataFim,
  });
}
