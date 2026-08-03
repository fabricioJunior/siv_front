import 'package:produtos/domain/data/repositorios/i_produtos_repository.dart';
import 'package:produtos/models.dart';

class ExcluirProdutosEmLote {
  final IProdutosRepository _produtosRepository;

  ExcluirProdutosEmLote({required IProdutosRepository produtosRepository})
      : _produtosRepository = produtosRepository;

  Future<ExclusaoProdutosEmLoteResultado> call(List<int> ids) {
    return _produtosRepository.excluirProdutosEmLote(ids);
  }
}
