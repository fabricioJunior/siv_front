import '../data/repositories/i_orcamento_repository.dart';

class ExcluirOrcamento {
  final IOrcamentoRepository _repository;

  ExcluirOrcamento({required IOrcamentoRepository repository})
      : _repository = repository;

  Future<void> call(String hash) {
    return _repository.excluir(hash);
  }
}
