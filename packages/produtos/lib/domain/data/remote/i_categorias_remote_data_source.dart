import 'package:produtos/models.dart';

abstract class ICategoriasRemoteDataSource {
  Future<Categoria> createCategoria(String nome, {String? ncm});
  Future<List<Categoria>> fetchCategorias({String? nome, bool? inativa});
  Future<Categoria?> fetchCategoria(int id);
  Future<void> desativarCategoria(int id);
  Future<Categoria> atualizarCategoria(int id, String nome, {String? ncm});
}
