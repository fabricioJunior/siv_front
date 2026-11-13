import 'package:financeiro/data.dart';
import 'package:financeiro/domain/models/despesa_do_caixa.dart';

class RecuperarDespesasDoCaixa {
  final IDespesasDoCaixaRepository _repository;

  RecuperarDespesasDoCaixa({required IDespesasDoCaixaRepository repository})
      : _repository = repository;

  Future<List<DespesaDoCaixa>> call({required int caixaId}) {
    return _repository.recuperarDespesas(caixaId: caixaId);
  }
}
