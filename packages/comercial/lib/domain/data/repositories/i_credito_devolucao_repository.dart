import 'package:comercial/models.dart';

abstract class ICreditoDevolucaoRepository {
  Future<double> buscarSaldo({required int pessoaId});

  Future<List<CreditoDevolucaoMovimentacao>> buscarMovimentacoes({
    required int pessoaId,
    List<int>? empresaIds,
    DateTime? dataInicio,
    DateTime? dataFim,
  });

  Future<List<CreditoTransferivel>> buscarTransferiveis({
    required int pessoaId,
  });

  Future<ResultadoTransferenciaCredito> transferir({
    required int pessoaId,
    required List<int> romaneioIds,
  });

  /// [situacao]: disponivel | encerrado | todos.
  Future<List<CreditoDevolucao>> buscarCreditos({
    required int pessoaId,
    required String situacao,
  });

  Future<ResumoCreditoDevolucao> buscarResumo({required int pessoaId});

  Future<ResultadoAcaoCredito> adicionar({
    required int pessoaId,
    required double valor,
    required String motivo,
    required String observacao,
    DateTime? validade,
    int? empresaId,
  });

  /// [valor] nulo remove todo o restante.
  Future<ResultadoAcaoCredito> remover({
    required int pessoaId,
    required int creditoId,
    double? valor,
    required String motivo,
    String? observacao,
  });

  Future<ResultadoAcaoCredito> expirar({
    required int pessoaId,
    required int creditoId,
    String? motivo,
  });
}
