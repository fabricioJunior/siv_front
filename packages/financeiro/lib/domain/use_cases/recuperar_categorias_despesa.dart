import 'package:financeiro/domain/data/repositories/i_categorias_despesa_repository.dart';
import 'package:financeiro/domain/models/categoria_despesa.dart';

class RecuperarCategoriasDespesa {
  final ICategoriasDespesaRepository repository;

  RecuperarCategoriasDespesa({required this.repository});

  Future<List<CategoriaDespesa>> call({
    required int empresaId,
    String? filtro,
  }) {
    return repository.recuperarCategorias(empresaId: empresaId, filtro: filtro);
  }
}
