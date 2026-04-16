import 'package:financeiro/data.dart';
import 'package:financeiro/domain/models/suprimento.dart';

class RecuperarSuprimento {
  final ISuprimentosRepository _repository;

  RecuperarSuprimento({required ISuprimentosRepository repository})
      : _repository = repository;

  Future<Suprimento> call({
    required int caixaId,
    required int suprimentoId,
  }) {
    return _repository.recuperarSuprimento(
      caixaId: caixaId,
      suprimentoId: suprimentoId,
    );
  }
}
