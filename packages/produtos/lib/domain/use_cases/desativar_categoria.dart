import 'package:produtos/repositorios.dart';

class DesativarCategoria {
  final ICategoriasRepository _categoriasRepository;

  DesativarCategoria({required ICategoriasRepository categoriasRepository})
    : _categoriasRepository = categoriasRepository;

  Future<void> call(int id) {
    return _categoriasRepository.desativarCategoria(id);
  }
}
