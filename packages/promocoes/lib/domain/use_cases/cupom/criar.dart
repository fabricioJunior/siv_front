import 'package:promocoes/domain/data/repositories/i_cupons_repository.dart';
import 'package:promocoes/domain/models/cupom.dart';

class CriarCupom {
  final ICuponsRepository _repository;

  CriarCupom({required ICuponsRepository repository}) : _repository = repository;

  Future<Cupom> call(Cupom cupom) {
    return _repository.criarCupom(cupom);
  }
}
