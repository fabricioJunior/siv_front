import 'package:financeiro/domain/data/repositories/i_despesas_repository.dart';
import 'package:financeiro/domain/models/despesa.dart';

class ApagarDespesa {
  final IDespesasRepository repository;

  ApagarDespesa({required this.repository});

  Future<void> call(
    int id, {
    EscopoExclusaoDespesa escopo = EscopoExclusaoDespesa.esta,
  }) {
    return repository.apagarDespesa(id, escopo: escopo);
  }
}
