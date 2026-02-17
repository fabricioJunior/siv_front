import 'package:produtos/models.dart';

abstract class ISubCategoriasRepository {
  Future<SubCategoria> criarSubCategoria(int categoriaId, String nome);
  Future<List<SubCategoria>> obterSubCategorias(
    int categoriaId, {
    String? nome,
    bool? inativa,
  });
  Future<SubCategoria?> obterSubCategoria(int categoriaId, int id);
  Future<void> desativarSubCategoria(int categoriaId, int id);
  Future<SubCategoria> atualizarSubCategoria(
    int categoriaId,
    int id,
    String nome,
  );
}
