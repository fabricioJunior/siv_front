import 'package:estoque/domain/data/repositorios/i_historico_estoque_repository.dart';
import 'package:estoque/domain/models/filtro_historico_estoque.dart';
import 'package:estoque/domain/models/pagina_historico_estoque.dart';

class RecuperarHistoricoDeEstoque {
  final IHistoricoEstoqueRepository _historicoEstoqueRepository;

  RecuperarHistoricoDeEstoque({
    required IHistoricoEstoqueRepository historicoEstoqueRepository,
  }) : _historicoEstoqueRepository = historicoEstoqueRepository;

  Future<PaginaHistoricoEstoque> call({
    required FiltroHistoricoEstoque filtro,
  }) {
    return _historicoEstoqueRepository.obterHistorico(filtro: filtro);
  }
}
