import 'package:produtos/models.dart';
import 'package:produtos/repositorios.dart';

class AtualizarSubCategoria {
  final ISubCategoriasRepository _subCategoriasRepository;

  AtualizarSubCategoria({
    required ISubCategoriasRepository subCategoriasRepository,
  }) : _subCategoriasRepository = subCategoriasRepository;

  Future<SubCategoria> call(
    int categoriaId,
    int id,
    String nome, {
    String? ncm,
    int? pesoGramas,
  }) {
    return _subCategoriasRepository.atualizarSubCategoria(
      categoriaId,
      id,
      nome,
      ncm: ncm,
      pesoGramas: pesoGramas,
    );
  }
}
