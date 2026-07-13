import 'package:comercial/domain/data/repositories/i_romaneios_repository.dart';
import 'package:comercial/domain/models/romaneio.dart';

class AtualizarVendedorRomaneio {
  final IRomaneiosRepository _repository;

  AtualizarVendedorRomaneio({
    required IRomaneiosRepository repository,
  }) : _repository = repository;

  Future<Romaneio> call(int id, int funcionarioId) {
    return _repository.atualizarVendedor(id, funcionarioId);
  }
}
