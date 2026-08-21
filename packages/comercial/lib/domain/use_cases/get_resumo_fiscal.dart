import 'package:comercial/domain/data/repositories/i_integracao_fiscal_repository.dart';
import 'package:comercial/domain/models/resumo_fiscal.dart';

class GetResumoFiscal {
  final IIntegracaoFiscalRepository _repository;

  GetResumoFiscal({required IIntegracaoFiscalRepository repository})
      : _repository = repository;

  Future<ResumoFiscal> call({
    int? romaneioId,
    int? pedidoId,
    String? cliente,
    String? status,
    String? formaPagamento,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) =>
      _repository.getResumo(
        romaneioId: romaneioId,
        pedidoId: pedidoId,
        cliente: cliente,
        status: status,
        formaPagamento: formaPagamento,
        dataInicio: dataInicio,
        dataFim: dataFim,
      );
}
