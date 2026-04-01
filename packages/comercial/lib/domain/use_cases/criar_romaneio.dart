import 'package:comercial/domain/data/repositories/i_romaneios_repository.dart';
import 'package:comercial/domain/models/romaneio.dart';

class CriarRomaneio {
  final IRomaneiosRepository _repository;

  CriarRomaneio({
    required IRomaneiosRepository repository,
  }) : _repository = repository;

  Future<Romaneio> call(Romaneio romaneio) =>
      _repository.criarRomaneio(romaneio);
}
