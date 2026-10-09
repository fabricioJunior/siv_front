import 'package:estoque/domain/data/repositorios/i_relatorio_estoque_repository.dart';
import 'package:estoque/domain/models/relatorio_giro_estoque.dart';

class GetResumoGiroEstoque {
  final IRelatorioEstoqueRepository _repository;
  GetResumoGiroEstoque({required IRelatorioEstoqueRepository repository})
    : _repository = repository;

  Future<GiroEstoqueResumo> call({
    required List<int> empresaIds,
    required FiltroGiroEstoque filtro,
  }) => _repository.giroResumo(empresaIds: empresaIds, filtro: filtro);
}
