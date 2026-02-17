import 'package:produtos/repositorios.dart';

class DesativarSubCategoria {
  final ISubCategoriasRepository _subCategoriasRepository;

  DesativarSubCategoria({
    required ISubCategoriasRepository subCategoriasRepository,
  }) : _subCategoriasRepository = subCategoriasRepository;

  Future<void> call(int categoriaId, int id) {
    return _subCategoriasRepository.desativarSubCategoria(categoriaId, id);
  }
}
