import 'package:financeiro/data.dart';
import 'package:financeiro/domain/models/sangria.dart';

class RecuperarSangrias {
  final ISangriasRepository _repository;

  RecuperarSangrias({required ISangriasRepository repository})
      : _repository = repository;

  Future<List<Sangria>> call({required int caixaId}) {
    return _repository.recuperarSangrias(caixaId: caixaId);
  }
}
