import 'package:produtos/models.dart';

abstract class ISubCategoriasRemoteDataSource {
  Future<SubCategoria> createSubCategoria(int categoriaId, String nome, {String? ncm});
  Future<List<SubCategoria>> fetchSubCategorias(
    int categoriaId, {
    String? nome,
    bool? inativa,
  });
  Future<SubCategoria?> fetchSubCategoria(int categoriaId, int id);
  Future<void> desativarSubCategoria(int categoriaId, int id);
  Future<SubCategoria> atualizarSubCategoria(
    int categoriaId,
    int id,
    String nome, {
    String? ncm,
  });
}
