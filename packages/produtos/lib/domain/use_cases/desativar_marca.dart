import 'package:produtos/repositorios.dart';

class DesativarMarca {
  final IMarcasRepository _marcasRepository;

  DesativarMarca({required IMarcasRepository marcasRepository})
    : _marcasRepository = marcasRepository;

  Future<void> call(int id) {
    return _marcasRepository.desativarMarca(id);
  }
}
