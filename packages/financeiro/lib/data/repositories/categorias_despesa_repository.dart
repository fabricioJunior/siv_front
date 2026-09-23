import 'package:financeiro/domain/data/remote/i_categorias_despesa_remote_data_source.dart';
import 'package:financeiro/domain/data/repositories/i_categorias_despesa_repository.dart';
import 'package:financeiro/domain/models/categoria_despesa.dart';

class CategoriasDespesaRepository implements ICategoriasDespesaRepository {
  final ICategoriasDespesaRemoteDataSource remoteDataSource;

  CategoriasDespesaRepository({required this.remoteDataSource});

  @override
  Future<List<CategoriaDespesa>> recuperarCategorias({
    required int empresaId,
    String? filtro,
  }) {
    return remoteDataSource.recuperarCategorias(
      empresaId: empresaId,
      filtro: filtro,
    );
  }

  @override
  Future<CategoriaDespesa?> recuperarCategoria(int id) {
    return remoteDataSource.recuperarCategoria(id);
  }

  @override
  Future<CategoriaDespesa> criarCategoria(CategoriaDespesa categoria) {
    return remoteDataSource.criarCategoria(categoria);
  }

  @override
  Future<CategoriaDespesa> atualizarCategoria(CategoriaDespesa categoria) {
    return remoteDataSource.atualizarCategoria(categoria);
  }
}
