import 'package:produtos/models.dart';

abstract class ICategoriasRemoteDataSource {
  Future<Categoria> createCategoria(String nome);
  Future<List<Categoria>> fetchCategorias({String? nome, bool? inativa});
  Future<Categoria?> fetchCategoria(int id);
  Future<void> desativarCategoria(int id);
  Future<Categoria> atualizarCategoria(int id, String nome);
}
