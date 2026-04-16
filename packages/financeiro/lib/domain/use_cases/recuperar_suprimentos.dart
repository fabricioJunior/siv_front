import 'package:financeiro/data.dart';
import 'package:financeiro/domain/models/suprimento.dart';

class RecuperarSuprimentos {
  final ISuprimentosRepository _repository;

  RecuperarSuprimentos({required ISuprimentosRepository repository})
      : _repository = repository;

  Future<List<Suprimento>> call({required int caixaId}) {
    return _repository.recuperarSuprimentos(caixaId: caixaId);
  }
}
