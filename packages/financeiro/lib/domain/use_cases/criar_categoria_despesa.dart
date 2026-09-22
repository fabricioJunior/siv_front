import 'package:financeiro/domain/data/repositories/i_categorias_despesa_repository.dart';
import 'package:financeiro/domain/models/categoria_despesa.dart';

class CriarCategoriaDespesa {
  final ICategoriasDespesaRepository repository;

  CriarCategoriaDespesa({required this.repository});

  Future<CategoriaDespesa> call(CategoriaDespesa categoria) =>
      repository.criarCategoria(categoria);
}
