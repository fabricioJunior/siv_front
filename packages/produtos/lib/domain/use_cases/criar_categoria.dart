import 'package:produtos/models.dart';
import 'package:produtos/repositorios.dart';

class CriarCategoria {
  final ICategoriasRepository _categoriasRepository;

  CriarCategoria({required ICategoriasRepository categoriasRepository})
    : _categoriasRepository = categoriasRepository;

  Future<Categoria> call(String nome) async {
    return _categoriasRepository.criarCategoria(nome);
  }
}
