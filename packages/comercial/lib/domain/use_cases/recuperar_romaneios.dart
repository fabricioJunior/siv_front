import 'package:comercial/domain/data/repositories/i_romaneios_repository.dart';
import 'package:comercial/domain/models/romaneio.dart';

class RecuperarRomaneios {
  final IRomaneiosRepository _repository;

  RecuperarRomaneios({
    required IRomaneiosRepository repository,
  }) : _repository = repository;

  Future<List<Romaneio>> call({int page = 1, int limit = 50}) {
    return _repository.recuperarRomaneios(page: page, limit: limit);
  }
}
