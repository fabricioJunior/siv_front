import 'package:produtos/models.dart';
import 'package:produtos/repositorios.dart';

class RecuperarSubCategorias {
  final ISubCategoriasRepository _subCategoriasRepository;

  RecuperarSubCategorias({
    required ISubCategoriasRepository subCategoriasRepository,
  }) : _subCategoriasRepository = subCategoriasRepository;

  Future<List<SubCategoria>> call(
    int categoriaId, {
    String? nome,
    bool? inativa,
  }) {
    return _subCategoriasRepository.obterSubCategorias(
      categoriaId,
      nome: nome,
      inativa: inativa,
    );
  }
}
