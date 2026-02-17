import 'package:produtos/models.dart';

abstract class ICategoriasRepository {
  Future<Categoria> criarCategoria(String nome);
  Future<List<Categoria>> obterCategorias({String? nome, bool? inativa});
  Future<Categoria?> obterCategoria(int id);
  Future<void> desativarCategoria(int id);

  Future<Categoria> atualizarCategoria(int id, String nome);
}
