import 'package:estoque/domain/models/relatorio_produtos_defasados.dart';
import 'package:estoque/domain/models/relatorio_giro_estoque.dart';

abstract class IRelatorioEstoqueRepository {
  Future<RelatorioProdutosDefasados> produtosDefasados({
    required List<int> empresaIds,
    int dias = 90,
    String tipoMovimentacao = 'ambas',
    String visualizacao = 'produto',
    String? dataReferencia,
    List<int>? produtoIds,
    List<int>? referenciaIds,
    List<int>? categoriaIds,
    List<int>? corIds,
    List<int>? tamanhoIds,
    ModoAgrupamentoReferencia modoAgrupamentoReferencia =
        ModoAgrupamentoReferencia.todos,
    String? busca,
    int page = 1,
    int limit = 100,
  });

  Future<PaginaGiroEstoque> giro({
    required List<int> empresaIds,
    required FiltroGiroEstoque filtro,
    required AbaGiro aba,
    required String ordenarPor,
    required String ordem,
    int page = 1,
    int limit = 20,
  });

  Future<GiroEstoqueResumo> giroResumo({
    required List<int> empresaIds,
    required FiltroGiroEstoque filtro,
  });

  Future<GiroEstoqueVariacoes> giroVariacoes({
    required int referenciaId,
    required List<int> empresaIds,
    required FiltroGiroEstoque filtro,
  });
}
