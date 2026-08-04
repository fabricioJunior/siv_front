import 'package:comercial/domain/data/repositories/i_romaneios_repository.dart';
import 'package:comercial/domain/models/romaneio.dart';

class FinalizarRomaneio {
  final IRomaneiosRepository _repository;

  FinalizarRomaneio({
    required IRomaneiosRepository repository,
  }) : _repository = repository;

  Future<Romaneio> call(int id) {
    return _repository.finalizarRomaneio(id);
  }
}
