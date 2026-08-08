import 'package:promocoes/domain/data/repositories/i_cupons_repository.dart';
import 'package:promocoes/domain/models/cupom.dart';

class AtualizarCupom {
  final ICuponsRepository _repository;

  AtualizarCupom({required ICuponsRepository repository})
      : _repository = repository;

  Future<Cupom> call(Cupom cupom) {
    return _repository.atualizarCupom(cupom);
  }
}
