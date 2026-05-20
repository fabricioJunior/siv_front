import 'package:comercial/data.dart';
import 'package:comercial/models.dart';

class BuscarCreditoDevolucaoMovimentacoes {
  final ICreditoDevolucaoRepository _repository;

  BuscarCreditoDevolucaoMovimentacoes({
    required ICreditoDevolucaoRepository repository,
  }) : _repository = repository;

  Future<List<CreditoDevolucaoMovimentacao>> call({
    required int pessoaId,
    List<int>? empresaIds,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) {
    return _repository.buscarMovimentacoes(
      pessoaId: pessoaId,
      empresaIds: empresaIds,
      dataInicio: dataInicio,
      dataFim: dataFim,
    );
  }
}
