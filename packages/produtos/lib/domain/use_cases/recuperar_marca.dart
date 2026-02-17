import 'package:produtos/domain/models/marca.dart';
import 'package:produtos/repositorios.dart';

class RecuperarMarca {
  final IMarcasRepository _marcasRepository;

  RecuperarMarca({required IMarcasRepository marcasRepository})
    : _marcasRepository = marcasRepository;

  Future<Marca?> call(int id) {
    return _marcasRepository.obterMarca(id);
  }
}
