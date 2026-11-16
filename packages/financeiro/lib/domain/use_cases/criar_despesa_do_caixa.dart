import 'package:financeiro/data.dart';
import 'package:financeiro/domain/models/despesa_do_caixa.dart';

class CriarDespesaDoCaixa {
  final IDespesasDoCaixaRepository _repository;

  CriarDespesaDoCaixa({required IDespesasDoCaixaRepository repository})
      : _repository = repository;

  Future<DespesaDoCaixa> call({
    required int caixaId,
    required double valor,
    required String descricao,
    required int categoriaId,
  }) {
    return _repository.criarDespesa(
      caixaId: caixaId,
      valor: valor,
      descricao: descricao,
      categoriaId: categoriaId,
    );
  }
}
