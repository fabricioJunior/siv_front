import 'package:financeiro/domain/data/repositories/i_categorias_despesa_repository.dart';
import 'package:financeiro/domain/models/categoria_despesa.dart';

class RecuperarCategoriaDespesa {
  final ICategoriasDespesaRepository repository;

  RecuperarCategoriaDespesa({required this.repository});

  Future<CategoriaDespesa?> call(int id) => repository.recuperarCategoria(id);
}
