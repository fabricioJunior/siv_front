import 'package:produtos/domain/data/remote/i_categorias_remote_data_source.dart';
import 'package:produtos/domain/data/repositorios/i_categorias_repository.dart';
import 'package:produtos/domain/models/categoria.dart';

class CategoriasRepository implements ICategoriasRepository {
  final ICategoriasRemoteDataSource categoriasRemoteDataSource;

  CategoriasRepository({required this.categoriasRemoteDataSource});

  @override
  Future<Categoria> atualizarCategoria(int id, String nome) {
    return categoriasRemoteDataSource.atualizarCategoria(id, nome);
  }

  @override
  Future<Categoria> criarCategoria(String nome) {
    return categoriasRemoteDataSource.createCategoria(nome);
  }

  @override
  Future<void> desativarCategoria(int id) {
    return categoriasRemoteDataSource.desativarCategoria(id);
  }

  @override
  Future<Categoria?> obterCategoria(int id) {
    return categoriasRemoteDataSource.fetchCategoria(id);
  }

  @override
  Future<List<Categoria>> obterCategorias({String? nome, bool? inativa}) {
    return categoriasRemoteDataSource.fetchCategorias(
      nome: nome,
      inativa: inativa,
    );
  }
}
