import 'package:estoque/domain/data/repositorios/i_relatorio_estoque_repository.dart';
import 'package:estoque/domain/models/relatorio_produtos_defasados.dart';

class GetRelatorioProdutosDefasados {
  final IRelatorioEstoqueRepository _repository;
  GetRelatorioProdutosDefasados({required IRelatorioEstoqueRepository repository})
      : _repository = repository;

  Future<RelatorioProdutosDefasados> call({
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
    String? busca,
    int page = 1,
    int limit = 100,
  }) =>
      _repository.produtosDefasados(
        empresaIds: empresaIds,
        dias: dias,
        tipoMovimentacao: tipoMovimentacao,
        visualizacao: visualizacao,
        dataReferencia: dataReferencia,
        produtoIds: produtoIds,
        referenciaIds: referenciaIds,
        categoriaIds: categoriaIds,
        corIds: corIds,
        tamanhoIds: tamanhoIds,
        busca: busca,
        page: page,
        limit: limit,
      );
}
