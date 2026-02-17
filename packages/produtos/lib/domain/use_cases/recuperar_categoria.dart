import 'package:produtos/domain/models/categoria.dart';
import 'package:produtos/repositorios.dart';

class RecuperarCategoria {
  final ICategoriasRepository _categoriasRepository;

  RecuperarCategoria({required ICategoriasRepository categoriasRepository})
    : _categoriasRepository = categoriasRepository;

  Future<Categoria?> call(int id) {
    return _categoriasRepository.obterCategoria(id);
  }
}
