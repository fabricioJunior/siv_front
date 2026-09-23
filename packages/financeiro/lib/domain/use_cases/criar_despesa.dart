import 'package:financeiro/domain/data/repositories/i_despesas_repository.dart';
import 'package:financeiro/domain/models/despesa.dart';

class CriarDespesa {
  final IDespesasRepository repository;

  CriarDespesa({required this.repository});

  Future<Despesa> call(Despesa despesa) => repository.criarDespesa(despesa);
}
