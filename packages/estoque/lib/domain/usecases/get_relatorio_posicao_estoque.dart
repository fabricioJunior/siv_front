import 'package:estoque/domain/data/repositorios/i_relatorio_estoque_repository.dart';
import 'package:estoque/domain/models/relatorio_posicao_estoque.dart';

class GetRelatorioPosicaoEstoque {
  final IRelatorioEstoqueRepository _repository;
  GetRelatorioPosicaoEstoque({required IRelatorioEstoqueRepository repository})
      : _repository = repository;

  Future<RelatorioPosicaoEstoque> call({
    required List<int> empresaIds,
    String? dataReferencia,
    List<int>? categoriaIds,
    List<int>? corIds,
    List<int>? tamanhoIds,
    String? situacao,
    String ordenarPor = 'valor',
    String ordem = 'desc',
  }) =>
      _repository.posicaoEstoque(
        empresaIds: empresaIds,
        dataReferencia: dataReferencia,
        categoriaIds: categoriaIds,
        corIds: corIds,
        tamanhoIds: tamanhoIds,
        situacao: situacao,
        ordenarPor: ordenarPor,
        ordem: ordem,
      );
}
