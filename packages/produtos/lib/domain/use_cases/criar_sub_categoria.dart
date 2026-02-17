import 'package:produtos/models.dart';
import 'package:produtos/repositorios.dart';

class CriarSubCategoria {
  final ISubCategoriasRepository _subCategoriasRepository;

  CriarSubCategoria({required ISubCategoriasRepository subCategoriasRepository})
    : _subCategoriasRepository = subCategoriasRepository;

  Future<SubCategoria> call(int categoriaId, String nome) async {
    return _subCategoriasRepository.criarSubCategoria(categoriaId, nome);
  }
}
