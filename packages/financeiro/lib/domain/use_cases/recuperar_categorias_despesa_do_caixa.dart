import 'package:financeiro/data.dart';
import 'package:financeiro/domain/models/despesa_do_caixa.dart';

class RecuperarCategoriasDespesaDoCaixa {
  final IDespesasDoCaixaRepository _repository;

  RecuperarCategoriasDespesaDoCaixa({
    required IDespesasDoCaixaRepository repository,
  }) : _repository = repository;

  Future<List<CategoriaDespesaDoCaixa>> call({required int caixaId}) {
    return _repository.recuperarCategorias(caixaId: caixaId);
  }
}
