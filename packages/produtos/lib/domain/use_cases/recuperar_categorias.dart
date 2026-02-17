import 'package:produtos/models.dart';
import 'package:produtos/repositorios.dart';

class RecuperarCategorias {
  final ICategoriasRepository _categoriasRepository;

  RecuperarCategorias({required ICategoriasRepository categoriasRepository})
    : _categoriasRepository = categoriasRepository;

  Future<List<Categoria>> call({String? nome, bool? inativa}) {
    return _categoriasRepository.obterCategorias(nome: nome, inativa: inativa);
  }
}
