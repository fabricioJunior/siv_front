import 'package:promocoes/domain/data/repositories/i_cupons_repository.dart';
import 'package:promocoes/domain/models/cupom.dart';

class RecuperarCupom {
  final ICuponsRepository _repository;

  RecuperarCupom({required ICuponsRepository repository})
      : _repository = repository;

  Future<Cupom?> call(int id) {
    return _repository.recuperarCupom(id);
  }
}
