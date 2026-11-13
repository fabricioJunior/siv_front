import 'package:financeiro/data.dart';

class CancelarDespesaDoCaixa {
  final IDespesasDoCaixaRepository _repository;

  CancelarDespesaDoCaixa({required IDespesasDoCaixaRepository repository})
      : _repository = repository;

  Future<void> call({
    required int caixaId,
    required int despesaId,
    required String motivo,
  }) {
    return _repository.cancelarDespesa(
      caixaId: caixaId,
      despesaId: despesaId,
      motivo: motivo,
    );
  }
}
