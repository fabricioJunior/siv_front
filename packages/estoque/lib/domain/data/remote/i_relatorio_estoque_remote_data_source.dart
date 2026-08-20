import 'package:estoque/domain/models/relatorio_produtos_defasados.dart';

abstract class IRelatorioEstoqueRemoteDataSource {
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
}
