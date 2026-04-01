import 'package:comercial/domain/data/repositories/i_romaneios_repository.dart';
import 'package:comercial/domain/models/romaneio.dart';

class AtualizarRomaneio {
  final IRomaneiosRepository _repository;

  AtualizarRomaneio({
    required IRomaneiosRepository repository,
  }) : _repository = repository;

  Future<Romaneio> call(Romaneio romaneio) =>
      _repository.atualizarRomaneio(romaneio);
}
