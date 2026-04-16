import 'package:financeiro/data.dart';

class CancelarSuprimento {
  final ISuprimentosRepository _repository;

  CancelarSuprimento({required ISuprimentosRepository repository})
      : _repository = repository;

  Future<void> call({
    required int caixaId,
    required int suprimentoId,
    required String motivo,
  }) {
    return _repository.cancelarSuprimento(
      caixaId: caixaId,
      suprimentoId: suprimentoId,
      motivo: motivo,
    );
  }
}
