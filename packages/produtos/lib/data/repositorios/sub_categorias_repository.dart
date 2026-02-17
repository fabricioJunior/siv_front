import 'package:produtos/domain/data/remote/i_sub_categorias_remote_data_source.dart';
import 'package:produtos/domain/data/repositorios/i_sub_categorias_repository.dart';
import 'package:produtos/domain/models/sub_categoria.dart';

class SubCategoriasRepository implements ISubCategoriasRepository {
  final ISubCategoriasRemoteDataSource subCategoriasRemoteDataSource;

  SubCategoriasRepository({required this.subCategoriasRemoteDataSource});

  @override
  Future<SubCategoria> atualizarSubCategoria(
    int categoriaId,
    int id,
    String nome,
  ) {
    return subCategoriasRemoteDataSource.atualizarSubCategoria(
      categoriaId,
      id,
      nome,
    );
  }

  @override
  Future<SubCategoria> criarSubCategoria(int categoriaId, String nome) {
    return subCategoriasRemoteDataSource.createSubCategoria(categoriaId, nome);
  }

  @override
  Future<void> desativarSubCategoria(int categoriaId, int id) {
    return subCategoriasRemoteDataSource.desativarSubCategoria(categoriaId, id);
  }

  @override
  Future<SubCategoria?> obterSubCategoria(int categoriaId, int id) {
    return subCategoriasRemoteDataSource.fetchSubCategoria(categoriaId, id);
  }

  @override
  Future<List<SubCategoria>> obterSubCategorias(
    int categoriaId, {
    String? nome,
    bool? inativa,
  }) {
    return subCategoriasRemoteDataSource.fetchSubCategorias(
      categoriaId,
      nome: nome,
      inativa: inativa,
    );
  }
}
