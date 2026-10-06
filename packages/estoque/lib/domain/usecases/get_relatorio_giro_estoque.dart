import 'package:estoque/domain/data/repositorios/i_relatorio_estoque_repository.dart';
import 'package:estoque/domain/models/relatorio_giro_estoque.dart';

class GetRelatorioGiroEstoque {
  final IRelatorioEstoqueRepository _repository;
  GetRelatorioGiroEstoque({required IRelatorioEstoqueRepository repository})
      : _repository = repository;

  Future<PaginaGiroEstoque> call({
    required List<int> empresaIds,
    required FiltroGiroEstoque filtro,
    required AbaGiro aba,
    required String ordenarPor,
    required String ordem,
    int page = 1,
    int limit = 20,
  }) =>
      _repository.giro(
        empresaIds: empresaIds,
        filtro: filtro,
        aba: aba,
        ordenarPor: ordenarPor,
        ordem: ordem,
        page: page,
        limit: limit,
      );
}
