import 'package:financeiro/domain/data/repositories/i_categorias_despesa_repository.dart';
import 'package:financeiro/domain/models/categoria_despesa.dart';

class AtualizarCategoriaDespesa {
  final ICategoriasDespesaRepository repository;

  AtualizarCategoriaDespesa({required this.repository});

  Future<CategoriaDespesa> call(CategoriaDespesa categoria) =>
      repository.atualizarCategoria(categoria);
}
