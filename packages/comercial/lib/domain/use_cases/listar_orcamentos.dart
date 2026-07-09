import '../data/repositories/i_orcamento_repository.dart';
import '../models/orcamento_local.dart';

class ListarOrcamentos {
  final IOrcamentoRepository _repository;

  ListarOrcamentos({required IOrcamentoRepository repository})
      : _repository = repository;

  Future<List<OrcamentoLocal>> call() {
    return _repository.listar();
  }
}
