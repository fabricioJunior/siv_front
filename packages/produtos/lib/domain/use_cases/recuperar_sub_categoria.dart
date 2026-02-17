import 'package:produtos/domain/models/sub_categoria.dart';
import 'package:produtos/repositorios.dart';

class RecuperarSubCategoria {
  final ISubCategoriasRepository _subCategoriasRepository;

  RecuperarSubCategoria({
    required ISubCategoriasRepository subCategoriasRepository,
  }) : _subCategoriasRepository = subCategoriasRepository;

  Future<SubCategoria?> call(int categoriaId, int id) {
    return _subCategoriasRepository.obterSubCategoria(categoriaId, id);
  }
}
