import 'package:comercial/domain/data/repositories/i_romaneios_repository.dart';
import 'package:comercial/domain/models/romaneio_item.dart';

class RecuperarItensRomaneio {
  final IRomaneiosRepository _repository;

  RecuperarItensRomaneio({
    required IRomaneiosRepository repository,
  }) : _repository = repository;

  Future<List<RomaneioItem>> call(int romaneioId) =>
      _repository.recuperarItensRomaneio(romaneioId);
}
