import 'package:comercial/domain/data/repositories/i_integracao_fiscal_repository.dart';

class ListarDocumentosFiscais {
  final IIntegracaoFiscalRepository _repository;

  ListarDocumentosFiscais({required IIntegracaoFiscalRepository repository})
      : _repository = repository;

  Future<Map<String, dynamic>> call({
    int? romaneioId,
    int? pedidoId,
    String? cliente,
    String? status,
    String? formaPagamento,
    DateTime? dataInicio,
    DateTime? dataFim,
    int page = 1,
    int limit = 25,
  }) =>
      _repository.listarDocumentos(
        romaneioId: romaneioId,
        pedidoId: pedidoId,
        cliente: cliente,
        status: status,
        formaPagamento: formaPagamento,
        dataInicio: dataInicio,
        dataFim: dataFim,
        page: page,
        limit: limit,
      );
}
