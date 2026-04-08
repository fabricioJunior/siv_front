import 'package:comercial/domain/data/repositories/i_romaneios_repository.dart';
import 'package:comercial/domain/models/romaneio_item.dart';

class RemoverItemRomaneio {
  final IRomaneiosRepository _repository;

  RemoverItemRomaneio({
    required IRomaneiosRepository repository,
  }) : _repository = repository;

  Future<void> call({
    required int romaneioId,
    required RomaneioItem item,
  }) =>
      _repository.removerItemRomaneio(romaneioId, item);
}
