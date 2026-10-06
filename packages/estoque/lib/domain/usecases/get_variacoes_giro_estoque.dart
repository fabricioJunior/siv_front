import 'package:estoque/domain/data/repositorios/i_relatorio_estoque_repository.dart';
import 'package:estoque/domain/models/relatorio_giro_estoque.dart';

class GetVariacoesGiroEstoque {
  final IRelatorioEstoqueRepository _repository;
  GetVariacoesGiroEstoque({required IRelatorioEstoqueRepository repository})
      : _repository = repository;

  Future<GiroEstoqueVariacoes> call({
    required int referenciaId,
    required List<int> empresaIds,
    required FiltroGiroEstoque filtro,
  }) =>
      _repository.giroVariacoes(
        referenciaId: referenciaId,
        empresaIds: empresaIds,
        filtro: filtro,
      );
}
