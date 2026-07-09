import '../data/repositories/i_orcamento_repository.dart';
import '../models/orcamento_local.dart';

class SalvarOrcamento {
  final IOrcamentoRepository _repository;

  SalvarOrcamento({required IOrcamentoRepository repository})
      : _repository = repository;

  Future<OrcamentoLocal> call(OrcamentoLocal orcamento) {
    return _repository.salvar(orcamento);
  }
}
