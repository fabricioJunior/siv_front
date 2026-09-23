import 'package:financeiro/domain/models/categoria_despesa.dart';

abstract class ICategoriasDespesaRemoteDataSource {
  Future<List<CategoriaDespesa>> recuperarCategorias({
    required int empresaId,
    String? filtro,
  });

  Future<CategoriaDespesa?> recuperarCategoria(int id);

  Future<CategoriaDespesa> criarCategoria(CategoriaDespesa categoria);

  Future<CategoriaDespesa> atualizarCategoria(CategoriaDespesa categoria);
}
