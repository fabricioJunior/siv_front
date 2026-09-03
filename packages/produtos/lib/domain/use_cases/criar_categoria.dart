import 'package:produtos/models.dart';
import 'package:produtos/repositorios.dart';

class CriarCategoria {
  final ICategoriasRepository _categoriasRepository;

  CriarCategoria({required ICategoriasRepository categoriasRepository})
    : _categoriasRepository = categoriasRepository;

  Future<Categoria> call(
    String nome, {
    String? ncm,
    String? descricao,
    int? pesoGramas,
  }) async {
    return _categoriasRepository.criarCategoria(
      nome,
      ncm: ncm,
      descricao: descricao,
      pesoGramas: pesoGramas,
    );
  }
}
