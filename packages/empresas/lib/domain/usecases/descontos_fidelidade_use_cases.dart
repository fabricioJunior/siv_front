import 'package:empresas/domain/data/repositories/i_descontos_fidelidade_repository.dart';
import 'package:empresas/domain/entities/desconto_fidelidade.dart';

class ListarDescontosFidelidade {
  final IDescontosFidelidadeRepository _repository;

  ListarDescontosFidelidade({required IDescontosFidelidadeRepository repository})
      : _repository = repository;

  Future<List<DescontoFidelidade>> call(int empresaId) =>
      _repository.listar(empresaId);
}

class SalvarDescontoFidelidade {
  final IDescontosFidelidadeRepository _repository;

  SalvarDescontoFidelidade({required IDescontosFidelidadeRepository repository})
      : _repository = repository;

  Future<void> call(int empresaId, DescontoFidelidade desconto) =>
      _repository.salvar(empresaId, desconto);
}

class ExcluirDescontoFidelidade {
  final IDescontosFidelidadeRepository _repository;

  ExcluirDescontoFidelidade({required IDescontosFidelidadeRepository repository})
      : _repository = repository;

  Future<void> call(int empresaId, int id) => _repository.excluir(empresaId, id);
}
