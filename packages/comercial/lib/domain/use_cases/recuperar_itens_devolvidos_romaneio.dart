import 'package:comercial/domain/data/repositories/i_romaneios_repository.dart';
import 'package:comercial/domain/models/romaneio_item_devolvido.dart';

class RecuperarItensDevolvidosRomaneio {
  final IRomaneiosRepository _repository;

  RecuperarItensDevolvidosRomaneio({
    required IRomaneiosRepository repository,
  }) : _repository = repository;

  Future<List<RomaneioItemDevolvido>> call(int romaneioId) =>
      _repository.recuperarItensDevolvidosRomaneio(romaneioId);
}
