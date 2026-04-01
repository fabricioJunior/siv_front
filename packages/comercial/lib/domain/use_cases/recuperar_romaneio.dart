import 'package:comercial/domain/data/repositories/i_romaneios_repository.dart';
import 'package:comercial/domain/models/romaneio.dart';

class RecuperarRomaneio {
  final IRomaneiosRepository _repository;

  RecuperarRomaneio({
    required IRomaneiosRepository repository,
  }) : _repository = repository;

  Future<Romaneio> call(int id) => _repository.recuperarRomaneio(id);
}
