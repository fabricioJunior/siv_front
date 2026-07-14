import 'package:estoque/domain/models/filtro_historico_estoque.dart';
import 'package:estoque/domain/models/pagina_historico_estoque.dart';

abstract class IHistoricoEstoqueRepository {
  Future<PaginaHistoricoEstoque> obterHistorico({
    required FiltroHistoricoEstoque filtro,
  });
}
